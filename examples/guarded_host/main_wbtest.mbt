///|
test "guarded host invokes the executor only for an allowed call" {
  let permit = @moonpermit.compile_plan("allow-once", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=1, max_bytes=16L),
    ),
  ])
  let host = guarded_host(permit)
  let allowed = host.invoke("allow", ReadFile("docs/a.md"), 0L, 4L)
  assert_true(allowed.has_prefix("ALLOW"))
  assert_eq(host.executor.calls, 1)
  let exhausted = host.invoke("exhausted", ReadFile("docs/b.md"), 1L, 4L)
  assert_true(exhausted.has_prefix("DENY"))
  assert_eq(host.executor.calls, 1)
  assert_eq(host.decisions.length(), 2)
  assert_eq(
    host.decisions[0].receipt.sequence,
    host.decisions[0].proof.sequence,
  )
}

///|
test "guarded host denies scope, expiry, duplicate, and unsupported calls" {
  let permit = @moonpermit.compile_plan("deny-without-effects", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=4, expires_at=2L),
    ),
  ])
  let host = guarded_host(permit)
  ignore(host.invoke("outside", ReadFile(".env"), 0L, 0L))
  ignore(host.invoke("expired", ReadFile("docs/a.md"), 2L, 0L))
  ignore(host.invoke("outside", ReadFile("docs/a.md"), 1L, 0L))
  ignore(host.invoke("unknown", Unsupported("shell"), 1L, 0L))
  assert_eq(host.executor.calls, 0)
  assert_eq(host.runtime.receipt_count(), 3)
  assert_true(
    @moonpermit.audit_receipts(permit, host.runtime.receipts()).passed(),
  )
}

///|
test "guarded host demo is stable and reports approval plus audit evidence" {
  assert_eq(demo_lines(), [
    "ALLOW \"Granted\" executed=true value=fixture:docs/guide.md", "DENY \"CallBudgetExhausted\" executed=false",
    "DENY \"NoMatchingGrant\" executed=false", "DENY \"DuplicateInvocation\" executed=false",
    "DENY unsupported:shell executed=false", "needs_approval=true", "audit=true checked=4 executor_calls=1",
  ])
}
