///|
fn find_covering_grant(approved : Permit, requested : Grant) -> Grant? {
  let mut candidate : Grant? = None
  for grant in approved.grants {
    if grant_contains(grant, requested) {
      match candidate {
        None => candidate = Some(grant)
        Some(current) => {
          let grant_is_tighter = effect_contains(current.effect, grant.effect)
            is Containment::Contained &&
            !(effect_contains(grant.effect, current.effect)
            is Containment::Contained)
          if grant_is_tighter {
            candidate = Some(grant)
          }
        }
      }
    }
  }
  candidate
}

///|
pub fn diff_permits(approved : Permit, requested : Permit) -> PermitDiff {
  let entries : Array[DiffEntry] = []
  for grant in requested.grants {
    match find_covering_grant(approved, grant) {
      Some(parent) =>
        entries.push({
          effect: grant.effect.canonical(),
          budget: grant.budget.canonical(),
          verdict: Verdict::Allow,
          covered_by: Some(parent.id),
          explanation: "already covered by " + parent.id,
        })
      None =>
        entries.push({
          effect: grant.effect.canonical(),
          budget: grant.budget.canonical(),
          verdict: Verdict::NeedsApproval,
          covered_by: None,
          explanation: "scope or budget exceeds the approved permit",
        })
    }
  }
  { approved_id: approved.id, requested_id: requested.id, entries, }
}

///|
pub fn PermitDiff::entries(self : PermitDiff) -> Array[DiffEntry] {
  self.entries.copy()
}

///|
pub fn PermitDiff::requires_approval(self : PermitDiff) -> Bool {
  self.entries.any(entry => entry.verdict is Verdict::NeedsApproval)
}

///|
pub fn PermitDiff::render(self : PermitDiff) -> String {
  let lines : Array[String] = [
    "diff:" + self.approved_id + "->" + self.requested_id,
  ]
  for entry in self.entries {
    let status = match entry.verdict {
      Allow => "COVERED"
      Deny => "DENY"
      NeedsApproval => "NEEDS_APPROVAL"
    }
    let coverage = match entry.covered_by {
      Some(grant_id) => " via " + grant_id
      None => ""
    }
    lines.push(
      status +
      " " +
      entry.effect +
      " | " +
      entry.budget +
      coverage +
      " | " +
      entry.explanation,
    )
  }
  lines.join("\n")
}
