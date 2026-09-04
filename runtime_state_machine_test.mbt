///|
test "state machine: a call budget N allows exactly N invocations" {
  for limit in 1..<=8 {
    let permit = @moonpermit.compile_plan("finite-\{limit}", [
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_tree("docs")),
        @moonpermit.budget(max_calls=limit),
      ),
    ])
    let runtime = @moonpermit.runtime(permit)
    let mut allowed = 0
    for index in 0..<(limit + 3) {
      let receipt = runtime.check(
        "call-\{index}",
        @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
        index.to_int64(),
      )
      if receipt.allowed() {
        allowed += 1
      }
    }
    assert_eq(allowed, limit)
    assert_eq(runtime.remaining_budget("grant-1").unwrap().max_calls(), Some(0))
    assert_true(@moonpermit.audit_receipts(permit, runtime.receipts()).passed())
  }
}

///|
test "state machine: denials and replays never decrement counters" {
  let runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("denials", [
      @moonpermit.effect_request(
        @moonpermit.FileWrite(@moonpermit.path_exact("report.json")),
        @moonpermit.budget(max_calls=2, max_bytes=10L),
      ),
    ]),
  )
  ignore(
    runtime.check(
      "outside",
      @moonpermit.FileWrite(@moonpermit.path_exact(".env")),
      0L,
      byte_cost=1L,
    ),
  )
  ignore(
    runtime.check(
      "oversized",
      @moonpermit.FileWrite(@moonpermit.path_exact("report.json")),
      1L,
      byte_cost=11L,
    ),
  )
  ignore(
    runtime.check(
      "outside",
      @moonpermit.FileWrite(@moonpermit.path_exact("report.json")),
      2L,
      byte_cost=1L,
    ),
  )
  let remaining = runtime.remaining_budget("grant-1").unwrap()
  assert_eq(remaining.max_calls(), Some(2))
  assert_eq(remaining.max_bytes(), Some(10L))
}

///|
test "state machine: delegated finite calls are conserved" {
  for limit in 1..<=6 {
    let runtime = @moonpermit.runtime(
      @moonpermit.compile_plan("parent-\{limit}", [
        @moonpermit.effect_request(
          @moonpermit.FileRead(@moonpermit.path_tree("docs")),
          @moonpermit.budget(max_calls=limit),
        ),
      ]),
    )
    for index in 0..<limit {
      let child = runtime.delegate(
        "child-\{index}",
        [
          @moonpermit.effect_request(
            @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
            @moonpermit.budget(max_calls=1),
          ),
        ],
        0L,
      )
      assert_eq(child.grant_count(), 1)
    }
    try
      ignore(
        runtime.delegate(
          "one-too-many",
          [
            @moonpermit.effect_request(
              @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
              @moonpermit.budget(max_calls=1),
            ),
          ],
          0L,
        ),
      )
    catch {
      @moonpermit.PermitError::ChildAuthorityExceeded(_) => ()
      _ => fail("expected ChildAuthorityExceeded")
    } noraise {
      _ => fail("delegation must not exceed the parent call budget")
    }
    assert_eq(runtime.remaining_budget("grant-1").unwrap().max_calls(), Some(0))
  }
}
