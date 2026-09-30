///|
fn add_finding(
  findings : Array[AuditFinding],
  receipt_index : Int,
  code : AuditIssueCode,
  message : String,
) -> Unit {
  findings.push({ receipt_index, code, message, })
}

///|
pub fn audit_receipts(
  permit : Permit,
  receipts : Array[Receipt],
) -> AuditReport {
  let replay = runtime(permit)
  let findings : Array[AuditFinding] = []
  for index, supplied in receipts {
    let position = index + 1
    if supplied.sequence != position {
      add_finding(
        findings,
        position,
        AuditIssueCode::SequenceMismatch,
        "receipt sequence does not match its stream position",
      )
    }
    if supplied.permit_id != permit.id {
      add_finding(
        findings,
        position,
        AuditIssueCode::PermitMismatch,
        "receipt is bound to a different permit identifier",
      )
    }
    try {
      let expected = replay.check(
        supplied.invocation_id,
        supplied.requested,
        supplied.logical_time,
        byte_cost=supplied.byte_cost,
      )
      if expected != supplied {
        add_finding(
          findings,
          position,
          AuditIssueCode::ReplayMismatch,
          "receipt does not match deterministic replay",
        )
      }
    } catch {
      _ =>
        add_finding(
          findings,
          position,
          AuditIssueCode::InvalidReceipt,
          "receipt contains inputs rejected by the runtime",
        )
    }
  }
  { checked: receipts.length(), findings, }
}

///|
pub fn audit_events(permit : Permit, events : Array[AuditEvent]) -> AuditReport {
  let replay = runtime(permit)
  let findings : Array[AuditFinding] = []
  for index, supplied in events {
    let position = index + 1
    if supplied.sequence != position {
      add_finding(
        findings,
        position,
        AuditIssueCode::SequenceMismatch,
        "event sequence does not match its stream position",
      )
    }
    let supplied_permit = match supplied.kind {
      Checked(receipt) => receipt.permit_id
      Delegated(delegation) => delegation.parent_permit_id
    }
    if supplied_permit != permit.id {
      add_finding(
        findings,
        position,
        AuditIssueCode::PermitMismatch,
        "event is bound to a different permit identifier",
      )
    }
    try {
      match supplied.kind {
        Checked(receipt) =>
          ignore(
            replay.check(
              receipt.invocation_id,
              receipt.requested,
              receipt.logical_time,
              byte_cost=receipt.byte_cost,
            ),
          )
        Delegated(delegation) =>
          ignore(
            replay.delegate(
              delegation.child.id,
              delegation.child.grants.map(grant => {
                effect_request(grant.effect, grant.budget)
              }),
              delegation.logical_time,
            ),
          )
      }
      let expected = replay.events[replay.events.length() - 1]
      if expected != supplied {
        add_finding(
          findings,
          position,
          AuditIssueCode::ReplayMismatch,
          "event does not match deterministic replay",
        )
      }
    } catch {
      _ =>
        add_finding(
          findings,
          position,
          AuditIssueCode::InvalidReceipt,
          "event contains inputs rejected by the runtime",
        )
    }
  }
  { checked: events.length(), findings, }
}

///|
pub fn AuditReport::passed(self : AuditReport) -> Bool {
  self.findings.is_empty()
}

///|
pub fn AuditReport::checked(self : AuditReport) -> Int {
  self.checked
}

///|
pub fn AuditReport::findings(self : AuditReport) -> Array[AuditFinding] {
  self.findings.copy()
}
