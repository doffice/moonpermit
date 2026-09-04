///|
pub fn effect_request(effect : EffectScope, budget : Budget) -> EffectRequest {
  { effect, budget, }
}

///|
pub fn EffectRequest::effect(self : EffectRequest) -> EffectScope {
  self.effect
}

///|
pub fn EffectRequest::budget(self : EffectRequest) -> Budget {
  self.budget
}

///|
fn EffectRequest::canonical(self : EffectRequest) -> String {
  self.effect.canonical() + "|" + self.budget.canonical()
}

///|
fn merge_exact_requests(
  requests : Array[EffectRequest],
) -> Array[EffectRequest] {
  let merged : Array[EffectRequest] = []
  for request in requests {
    let mut duplicate : Int? = None
    for index, current in merged {
      if current.effect == request.effect {
        duplicate = Some(index)
        break
      }
    }
    match duplicate {
      Some(index) =>
        merged[index] = {
          effect: merged[index].effect,
          budget: budget_union(merged[index].budget, request.budget),
        }
      None => merged.push(request)
    }
  }
  merged
}

///|
pub fn compile_plan(
  permit_id : String,
  requests : Array[EffectRequest],
) -> Permit raise PermitError {
  let id = permit_id.trim().to_owned()
  if id is "" {
    raise PermitError::EmptyPermitId
  }
  if requests.is_empty() {
    raise PermitError::EmptyPlan
  }
  let merged = merge_exact_requests(requests)
  merged.sort_by((left, right) => left.canonical().compare(right.canonical()))
  let grants : Array[Grant] = []
  for index, request in merged {
    grants.push({
      id: "grant-\{index + 1}",
      effect: request.effect,
      budget: request.budget,
    })
  }
  { id, grants, }
}

///|
pub fn Permit::id(self : Permit) -> String {
  self.id
}

///|
pub fn Permit::grants(self : Permit) -> Array[Grant] {
  self.grants.copy()
}

///|
pub fn Permit::grant_count(self : Permit) -> Int {
  self.grants.length()
}

///|
pub fn Grant::id(self : Grant) -> String {
  self.id
}

///|
pub fn Grant::effect(self : Grant) -> EffectScope {
  self.effect
}

///|
pub fn Grant::budget(self : Grant) -> Budget {
  self.budget
}

///|
fn Grant::canonical(self : Grant) -> String {
  self.id + "|" + self.effect.canonical() + "|" + self.budget.canonical()
}

///|
pub fn Permit::canonical(self : Permit) -> String {
  let lines = self.grants.map(grant => grant.canonical())
  "permit:" + self.id + "\n" + lines.join("\n")
}

///|
pub fn grant_contains(grant : Grant, requested : Grant) -> Bool {
  effect_contains(grant.effect, requested.effect) is Containment::Contained &&
  budget_contains(grant.budget, requested.budget)
}

///|
pub fn permit_contains(grant : Permit, requested : Permit) -> Bool {
  for requested_grant in requested.grants {
    let mut covered = false
    for available_grant in grant.grants {
      if grant_contains(available_grant, requested_grant) {
        covered = true
        break
      }
    }
    if !covered {
      return false
    }
  }
  true
}
