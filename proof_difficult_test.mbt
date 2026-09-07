///|
test "proof: duplicate invocation stops before grant evaluation" {
  let effect = @moonpermit.SecretRead("deployment-token")
  let runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("proof-replay", [
      @moonpermit.effect_request(effect, @moonpermit.budget(max_calls=2)),
    ]),
  )
  ignore(runtime.check_with_proof("same-id", effect, 0L))
  let duplicate = runtime.check_with_proof("same-id", effect, 1L)
  assert_eq(
    duplicate.receipt.reason,
    @moonpermit.ReasonCode::DuplicateInvocation,
  )
  assert_eq(duplicate.proof.checks.length(), 1)
  assert_eq(
    duplicate.proof.checks[0].kind,
    @moonpermit.ProofCheckKind::InvocationUnique,
  )
  assert_eq(
    duplicate.proof.checks[0].status,
    @moonpermit.ProofCheckStatus::Fail,
  )
  assert_eq(runtime.remaining_budget("grant-1").unwrap().max_calls(), Some(1))
}

///|
test "proof: overlapping grants identify the selected grant without double use" {
  let exact_effect = @moonpermit.FileRead(
    @moonpermit.path_exact("docs/guide.md"),
  )
  let runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("proof-overlap", [
      @moonpermit.effect_request(exact_effect, @moonpermit.budget(max_calls=1)),
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_tree("docs")),
        @moonpermit.budget(max_calls=1),
      ),
    ]),
  )
  let exact = runtime.check_with_proof("exact", exact_effect, 0L)
  let sibling = runtime.check_with_proof(
    "sibling",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/other.md")),
    1L,
  )
  assert_eq(exact.receipt.grant_id, Some("grant-2"))
  assert_eq(exact.proof.decision_grant_id, Some("grant-2"))
  assert_eq(sibling.receipt.grant_id, Some("grant-1"))
  assert_eq(sibling.proof.decision_grant_id, Some("grant-1"))
  assert_eq(runtime.receipt_count(), 2)
  assert_eq(runtime.remaining_budget("grant-1").unwrap().max_calls(), Some(0))
  assert_eq(runtime.remaining_budget("grant-2").unwrap().max_calls(), Some(0))
}

///|
test "proof: check_with_proof consumes once and legacy check stays compatible" {
  let effect = @moonpermit.ProcessExec(
    @moonpermit.command_exact("moon", ["test"]),
  )
  let runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("proof-atomic", [
      @moonpermit.effect_request(
        effect,
        @moonpermit.budget(max_calls=2, max_bytes=10L),
      ),
    ]),
  )
  let decision = runtime.check_with_proof(
    "proof-call",
    effect,
    0L,
    byte_cost=3L,
  )
  assert_eq(decision.receipt.remaining_calls, Some(1))
  assert_eq(decision.receipt.remaining_bytes, Some(7L))
  let legacy = runtime.check("legacy-call", effect, 1L, byte_cost=3L)
  assert_eq(legacy.remaining_calls, Some(0))
  assert_eq(legacy.remaining_bytes, Some(4L))
  assert_eq(runtime.receipt_count(), 2)
}

///|
test "proof: equivalent fresh runtimes serialize deterministically" {
  let effect = @moonpermit.FileDelete(@moonpermit.path_exact("tmp/cache.json"))
  let permit = @moonpermit.compile_plan("proof-json", [
    @moonpermit.effect_request(
      effect,
      @moonpermit.budget(max_calls=1, max_bytes=2L, expires_at=9L),
    ),
  ])
  let first = @moonpermit.runtime(permit)
    .check_with_proof("stable", effect, 1L, byte_cost=2L)
    .to_json()
    .stringify()
  let second = @moonpermit.runtime(permit)
    .check_with_proof("stable", effect, 1L, byte_cost=2L)
    .to_json()
    .stringify()
  assert_eq(first, second)
}
