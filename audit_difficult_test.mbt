///|
test "offline audit detects reordered or altered evidence" {
  let permit = @moonpermit.compile_plan("audit-demo", [
    @moonpermit.effect_request(
      @moonpermit.FileWrite(@moonpermit.path_exact("report.json")),
      @moonpermit.budget(max_calls=1, max_bytes=10L),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let receipt = runtime.check(
    "write",
    @moonpermit.FileWrite(@moonpermit.path_exact("report.json")),
    1L,
    byte_cost=5L,
  )
  let wrong_sequence = { ..receipt, sequence: 9, }
  let altered_cost = { ..receipt, byte_cost: 6L, }
  let sequence_report = @moonpermit.audit_receipts(permit, [wrong_sequence])
  let cost_report = @moonpermit.audit_receipts(permit, [altered_cost])
  assert_false(sequence_report.passed())
  assert_false(cost_report.passed())
  assert_true(
    sequence_report
    .findings()
    .any(finding => finding.code is @moonpermit.AuditIssueCode::SequenceMismatch),
  )
  assert_true(
    cost_report
    .findings()
    .any(finding => finding.code is @moonpermit.AuditIssueCode::ReplayMismatch),
  )
}

///|
test "offline audit binds receipts to their permit" {
  let permit = @moonpermit.compile_plan("permit-a", [
    @moonpermit.effect_request(
      @moonpermit.SecretRead("token"),
      @moonpermit.budget(max_calls=1),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let receipt = runtime.check("read", @moonpermit.SecretRead("token"), 0L)
  let wrong_permit = { ..receipt, permit_id: "permit-b", }
  let report = @moonpermit.audit_receipts(permit, [wrong_permit])
  assert_false(report.passed())
  assert_true(
    report
    .findings()
    .any(finding => finding.code is @moonpermit.AuditIssueCode::PermitMismatch),
  )
}
