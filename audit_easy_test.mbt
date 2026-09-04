///|
test "offline audit accepts an untampered mixed decision stream" {
  let permit = @moonpermit.compile_plan("audit-demo", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=1, expires_at=20L),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  ignore(
    runtime.check(
      "allowed",
      @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
      1L,
    ),
  )
  ignore(
    runtime.check(
      "exhausted",
      @moonpermit.FileRead(@moonpermit.path_exact("docs/other.md")),
      2L,
    ),
  )
  ignore(
    runtime.check(
      "outside",
      @moonpermit.FileRead(@moonpermit.path_exact("README.md")),
      3L,
    ),
  )
  let report = @moonpermit.audit_receipts(permit, runtime.receipts())
  assert_true(report.passed())
  assert_eq(report.checked(), 3)
  assert_eq(report.findings().length(), 0)
}
