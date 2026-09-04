///|
test "runtime allows a covered effect and consumes its call budget" {
  let permit = @moonpermit.compile_plan("read-docs", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=1),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let first = runtime.check(
    "call-1",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    10L,
  )
  let second = runtime.check(
    "call-2",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/other.md")),
    11L,
  )
  assert_true(first.allowed())
  assert_eq(first.reason, @moonpermit.ReasonCode::Granted)
  assert_eq(first.remaining_calls, Some(0))
  assert_false(second.allowed())
  assert_eq(second.reason, @moonpermit.ReasonCode::CallBudgetExhausted)
}

///|
test "scope denial does not consume a matching grant" {
  let permit = @moonpermit.compile_plan("write-readme", [
    @moonpermit.effect_request(
      @moonpermit.FileWrite(@moonpermit.path_exact("README.md")),
      @moonpermit.budget(max_calls=1, max_bytes=100L),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let denied = runtime.check(
    "outside",
    @moonpermit.FileWrite(@moonpermit.path_exact(".env")),
    1L,
    byte_cost=10L,
  )
  let allowed = runtime.check(
    "inside",
    @moonpermit.FileWrite(@moonpermit.path_exact("README.md")),
    2L,
    byte_cost=10L,
  )
  assert_eq(denied.reason, @moonpermit.ReasonCode::NoMatchingGrant)
  assert_true(allowed.allowed())
  assert_eq(allowed.remaining_calls, Some(0))
  assert_eq(allowed.remaining_bytes, Some(90L))
}
