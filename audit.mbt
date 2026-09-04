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
