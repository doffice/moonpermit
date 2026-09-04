///|
fn available_budget(
  state : GrantState,
  remaining_calls : Int?,
  remaining_bytes : Int64?,
) -> Budget {
  {
    max_calls: remaining_calls,
    max_bytes: remaining_bytes,
    expires_at: state.grant.budget.expires_at,
  }
}

///|
fn reserve_calls(available : Int?, requested : Int?) -> Int? {
  match (available, requested) {
    (Some(available), Some(requested)) => Some(available - requested)
    _ => available
  }
}

///|
fn reserve_bytes(available : Int64?, requested : Int64?) -> Int64? {
  match (available, requested) {
    (Some(available), Some(requested)) => Some(available - requested)
    _ => available
  }
}

///|
fn grant_is_active(state : GrantState, now : Int64) -> Bool {
  match state.grant.budget.expires_at {
    Some(expiry) => now < expiry
    None => true
  }
}

///|
/// Prefer the tighter of two usable parents so broader authority remains
/// available for child requests that genuinely require it.
fn candidate_is_tighter(candidate : GrantState, current : GrantState) -> Bool {
  effect_contains(current.grant.effect, candidate.grant.effect)
  is Containment::Contained &&
  !(effect_contains(candidate.grant.effect, current.grant.effect)
  is Containment::Contained)
}

///|
pub fn Runtime::delegate(
  self : Runtime,
  child_id : String,
  requests : Array[EffectRequest],
  now : Int64,
) -> Permit raise PermitError {
  if now < 0L {
    raise PermitError::InvalidLogicalTime(now)
  }
  let child = compile_plan(child_id, requests)
  let calls = self.states.map(state => state.remaining_calls)
  let bytes = self.states.map(state => state.remaining_bytes)
  for child_grant in child.grants {
    let mut candidate : Int? = None
    for index, state in self.states {
      let scope_matches = effect_contains(
          state.grant.effect,
          child_grant.effect,
        )
        is Containment::Contained
      let budget_matches = budget_contains(
        available_budget(state, calls[index], bytes[index]),
        child_grant.budget,
      )
      if grant_is_active(state, now) && scope_matches && budget_matches {
        match candidate {
          None => candidate = Some(index)
          Some(current) =>
            if candidate_is_tighter(state, self.states[current]) {
              candidate = Some(index)
            }
        }
        if state.grant.effect == child_grant.effect {
          break
        }
      }
    }
    match candidate {
      None =>
        raise PermitError::ChildAuthorityExceeded(
          child_grant.effect.canonical(),
        )
      Some(index) => {
        calls[index] = reserve_calls(calls[index], child_grant.budget.max_calls)
        bytes[index] = reserve_bytes(bytes[index], child_grant.budget.max_bytes)
      }
    }
  }
  for index, state in self.states {
    state.remaining_calls = calls[index]
    state.remaining_bytes = bytes[index]
  }
  child
}
