///|
test "runtime rejects replayed invocation identifiers" {
  let permit = @moonpermit.compile_plan("replay", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree(".")),
      @moonpermit.budget(max_calls=3),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let first = runtime.check(
    "same-id",
    @moonpermit.FileRead(@moonpermit.path_exact("README.md")),
    1L,
  )
  let replay = runtime.check(
    "same-id",
    @moonpermit.FileRead(@moonpermit.path_exact("LICENSE")),
    2L,
  )
  assert_true(first.allowed())
  assert_false(replay.allowed())
  assert_eq(replay.reason, @moonpermit.ReasonCode::DuplicateInvocation)
  assert_eq(runtime.receipt_count(), 2)
  assert_eq(runtime.receipts()[1].sequence, 2)
}

///|
test "expiry is exclusive and does not fall through to allow" {
  let permit = @moonpermit.compile_plan("expires", [
    @moonpermit.effect_request(
      @moonpermit.SecretRead("deploy-token"),
      @moonpermit.budget(max_calls=1, expires_at=50L),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let receipt = runtime.check(
    "late",
    @moonpermit.SecretRead("deploy-token"),
    50L,
  )
  assert_false(receipt.allowed())
  assert_eq(receipt.reason, @moonpermit.ReasonCode::PermitExpired)
}
