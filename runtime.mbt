///|
/// Mutable counters paired with one immutable compiled grant.
struct GrantState {
  grant : Grant
  mut remaining_calls : Int?
  mut remaining_bytes : Int64?
}

///|
pub fn runtime(permit : Permit) -> Runtime {
  let states : Array[GrantState] = []
  for grant in permit.grants {
    states.push({
      grant,
      remaining_calls: grant.budget.max_calls,
      remaining_bytes: grant.budget.max_bytes,
    })
  }
  {
    permit_id: permit.id,
    states,
    seen_invocations: Set([]),
    receipts: [],
    sequence: 0,
  }
}

///|
fn Runtime::emit(
  self : Runtime,
  invocation_id : String,
  requested : EffectScope,
  logical_time : Int64,
  byte_cost : Int64,
  verdict : Verdict,
  grant_id : String?,
  reason : ReasonCode,
  message : String,
  remaining_calls : Int?,
  remaining_bytes : Int64?,
) -> Receipt {
  self.sequence = self.sequence + 1
  let receipt = {
    sequence: self.sequence,
    invocation_id,
    permit_id: self.permit_id,
    verdict,
    grant_id,
    requested,
    effect: requested.canonical(),
    logical_time,
    byte_cost,
    reason,
    message,
    remaining_calls,
    remaining_bytes,
  }
  self.receipts.push(receipt)
  receipt
}

///|
fn reason_message(reason : ReasonCode) -> String {
  match reason {
    Granted => "effect is covered and its budget was consumed"
    NoMatchingGrant => "no grant contains the requested effect"
    PermitExpired =>
      "a matching grant is expired and no usable alternative exists"
    CallBudgetExhausted =>
      "a matching grant has no calls remaining and no usable alternative exists"
    ByteBudgetExhausted =>
      "a matching grant has insufficient bytes and no usable alternative exists"
    DuplicateInvocation => "invocation identifier has already been checked"
  }
}

///|
pub fn Runtime::check(
  self : Runtime,
  invocation_id : String,
  requested : EffectScope,
  now : Int64,
  byte_cost? : Int64 = 0L,
) -> Receipt raise PermitError {
  let id = invocation_id.trim().to_owned()
  if id is "" {
    raise PermitError::EmptyInvocationId
  }
  if now < 0L {
    raise PermitError::InvalidLogicalTime(now)
  }
  if byte_cost < 0L {
    raise PermitError::InvalidByteCost(byte_cost)
  }
  if !self.seen_invocations.add_and_check(id) {
    return self.emit(
      id,
      requested,
      now,
      byte_cost,
      Verdict::Deny,
      None,
      ReasonCode::DuplicateInvocation,
      reason_message(DuplicateInvocation),
      None,
      None,
    )
  }
  let mut matched = false
  let mut denial_reason = ReasonCode::NoMatchingGrant
  let mut denial_grant : String? = None
  let mut denial_calls : Int? = None
  let mut denial_bytes : Int64? = None
  let mut candidate : Int? = None
  for index, state in self.states {
    if effect_contains(state.grant.effect, requested) is Containment::Contained {
      let expired = match state.grant.budget.expires_at {
        Some(expiry) => now >= expiry
        None => false
      }
      let calls_exhausted = match state.remaining_calls {
        Some(remaining) => remaining <= 0
        None => false
      }
      let bytes_exhausted = match state.remaining_bytes {
        Some(remaining) => byte_cost > remaining
        None => false
      }
      if expired || calls_exhausted || bytes_exhausted {
        if !matched {
          matched = true
          denial_reason = if expired {
            ReasonCode::PermitExpired
          } else if calls_exhausted {
            ReasonCode::CallBudgetExhausted
          } else {
            ReasonCode::ByteBudgetExhausted
          }
          denial_grant = Some(state.grant.id)
          denial_calls = state.remaining_calls
          denial_bytes = state.remaining_bytes
        }
        continue
      }
      match candidate {
        None => candidate = Some(index)
        Some(current) =>
          if candidate_is_tighter(state, self.states[current]) {
            candidate = Some(index)
          }
      }
      if state.grant.effect == requested {
        break
      }
    }
  }
  match candidate {
    Some(index) => {
      let state = self.states[index]
      match state.remaining_calls {
        Some(remaining) => state.remaining_calls = Some(remaining - 1)
        None => ()
      }
      match state.remaining_bytes {
        Some(remaining) => state.remaining_bytes = Some(remaining - byte_cost)
        None => ()
      }
      return self.emit(
        id,
        requested,
        now,
        byte_cost,
        Verdict::Allow,
        Some(state.grant.id),
        ReasonCode::Granted,
        reason_message(Granted),
        state.remaining_calls,
        state.remaining_bytes,
      )
    }
    None => ()
  }
  self.emit(
    id,
    requested,
    now,
    byte_cost,
    Verdict::Deny,
    denial_grant,
    denial_reason,
    reason_message(denial_reason),
    denial_calls,
    denial_bytes,
  )
}

///|
pub fn Runtime::permit_id(self : Runtime) -> String {
  self.permit_id
}

///|
pub fn Runtime::receipt_count(self : Runtime) -> Int {
  self.receipts.length()
}

///|
pub fn Runtime::receipts(self : Runtime) -> Array[Receipt] {
  self.receipts.copy()
}

///|
pub fn Runtime::remaining_budget(self : Runtime, grant_id : String) -> Budget? {
  for state in self.states {
    if state.grant.id == grant_id {
      return Some({
        max_calls: state.remaining_calls,
        max_bytes: state.remaining_bytes,
        expires_at: state.grant.budget.expires_at,
      })
    }
  }
  None
}

///|
pub fn Receipt::allowed(self : Receipt) -> Bool {
  self.verdict is Verdict::Allow
}
