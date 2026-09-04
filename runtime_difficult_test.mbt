///|
test "byte exhaustion does not consume a call" {
  let permit = @moonpermit.compile_plan("bytes", [
    @moonpermit.effect_request(
      @moonpermit.FileWrite(@moonpermit.path_exact("report.json")),
      @moonpermit.budget(max_calls=2, max_bytes=8L),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let oversized = runtime.check(
    "large",
    @moonpermit.FileWrite(@moonpermit.path_exact("report.json")),
    1L,
    byte_cost=9L,
  )
  let valid = runtime.check(
    "small",
    @moonpermit.FileWrite(@moonpermit.path_exact("report.json")),
    2L,
    byte_cost=8L,
  )
  assert_eq(oversized.reason, @moonpermit.ReasonCode::ByteBudgetExhausted)
  assert_true(valid.allowed())
  assert_eq(valid.remaining_calls, Some(1))
  assert_eq(valid.remaining_bytes, Some(0L))
}

///|
test "runtime selects another usable grant after an exhausted match" {
  let narrow = @moonpermit.effect_request(
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    @moonpermit.budget(max_calls=1),
  )
  let broad = @moonpermit.effect_request(
    @moonpermit.FileRead(@moonpermit.path_tree("docs")),
    @moonpermit.budget(max_calls=1),
  )
  let runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("fallback", [narrow, broad]),
  )
  let first = runtime.check(
    "first",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    1L,
  )
  let second = runtime.check(
    "second",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    2L,
  )
  assert_true(first.allowed())
  assert_true(second.allowed())
  assert_true(first.grant_id != second.grant_id)
}

///|
test "runtime preserves broad authority by consuming the tightest grant first" {
  let narrow = @moonpermit.effect_request(
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    @moonpermit.budget(max_calls=1),
  )
  let broad = @moonpermit.effect_request(
    @moonpermit.FileRead(@moonpermit.path_tree("docs")),
    @moonpermit.budget(max_calls=1),
  )
  let runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("tightest-runtime", [narrow, broad]),
  )
  let exact = runtime.check(
    "exact",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    1L,
  )
  let sibling = runtime.check(
    "sibling",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/other.md")),
    2L,
  )
  assert_true(exact.allowed())
  assert_true(sibling.allowed())
  assert_eq(exact.grant_id, Some("grant-2"))
  assert_eq(sibling.grant_id, Some("grant-1"))
}

///|
test "invalid runtime metadata fails before producing a receipt" {
  let runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("validation", [
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_tree(".")),
        @moonpermit.unlimited_budget(),
      ),
    ]),
  )
  let effect = @moonpermit.FileRead(@moonpermit.path_exact("README.md"))
  try ignore(runtime.check("   ", effect, 0L)) catch {
    @moonpermit.PermitError::EmptyInvocationId => ()
    _ => fail("expected EmptyInvocationId")
  } noraise {
    _ => fail("empty invocation identifier should be rejected")
  }
  try ignore(runtime.check("negative-time", effect, -1L)) catch {
    @moonpermit.PermitError::InvalidLogicalTime(-1L) => ()
    _ => fail("expected InvalidLogicalTime")
  } noraise {
    _ => fail("negative logical time should be rejected")
  }
  try ignore(runtime.check("negative-bytes", effect, 0L, byte_cost=-1L)) catch {
    @moonpermit.PermitError::InvalidByteCost(-1L) => ()
    _ => fail("expected InvalidByteCost")
  } noraise {
    _ => fail("negative byte cost should be rejected")
  }
  assert_eq(runtime.receipt_count(), 0)
}
