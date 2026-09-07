///|
test "proof: allowed decision records every successful check atomically" {
  let effect = @moonpermit.FileRead(@moonpermit.path_exact("README.md"))
  let runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("proof-allow", [
      @moonpermit.effect_request(
        effect,
        @moonpermit.budget(max_calls=2, max_bytes=10L, expires_at=10L),
      ),
    ]),
  )
  let decision = runtime.check_with_proof("allow-1", effect, 1L, byte_cost=4L)
  assert_true(decision.receipt.allowed())
  assert_eq(decision.proof.verdict, @moonpermit.Verdict::Allow)
  assert_eq(decision.proof.reason, @moonpermit.ReasonCode::Granted)
  assert_eq(decision.proof.decision_grant_id, Some("grant-1"))
  assert_eq(decision.proof.sequence, decision.receipt.sequence)
  assert_eq(runtime.receipts(), [decision.receipt])
  assert_eq(decision.proof.checks.length(), 5)
  assert_eq(decision.proof.checks.map(check => check.kind), [
    @moonpermit.ProofCheckKind::InvocationUnique,
    @moonpermit.ProofCheckKind::ScopeContained,
    @moonpermit.ProofCheckKind::NotExpired,
    @moonpermit.ProofCheckKind::CallBudgetAvailable,
    @moonpermit.ProofCheckKind::ByteBudgetAvailable,
  ])
  for check in decision.proof.checks {
    assert_eq(check.status, @moonpermit.ProofCheckStatus::Pass)
  }
  let remaining = runtime.remaining_budget("grant-1").unwrap()
  assert_eq(remaining.max_calls(), Some(1))
  assert_eq(remaining.max_bytes(), Some(6L))
}

///|
test "proof: scope mismatch records skipped dependent checks" {
  let runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("proof-scope", [
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_tree("docs")),
        @moonpermit.budget(max_calls=1, max_bytes=8L),
      ),
    ]),
  )
  let decision = runtime.check_with_proof(
    "outside",
    @moonpermit.FileRead(@moonpermit.path_exact("README.md")),
    0L,
  )
  assert_eq(decision.receipt.reason, @moonpermit.ReasonCode::NoMatchingGrant)
  assert_eq(decision.proof.decision_grant_id, None)
  assert_eq(decision.proof.checks[1].status, @moonpermit.ProofCheckStatus::Fail)
  for index in 2..<5 {
    assert_eq(
      decision.proof.checks[index].status,
      @moonpermit.ProofCheckStatus::Skipped,
    )
  }
  let remaining = runtime.remaining_budget("grant-1").unwrap()
  assert_eq(remaining.max_calls(), Some(1))
  assert_eq(remaining.max_bytes(), Some(8L))
}

///|
test "proof: expiry, call, and byte failures are independently visible" {
  let effect = @moonpermit.FileWrite(@moonpermit.path_exact("report.json"))
  let expired = @moonpermit.runtime(
    @moonpermit.compile_plan("proof-expiry", [
      @moonpermit.effect_request(
        effect,
        @moonpermit.budget(max_calls=1, max_bytes=5L, expires_at=2L),
      ),
    ]),
  ).check_with_proof("expired", effect, 2L, byte_cost=1L)
  assert_eq(expired.receipt.reason, @moonpermit.ReasonCode::PermitExpired)
  assert_eq(expired.proof.checks[2].status, @moonpermit.ProofCheckStatus::Fail)
  assert_eq(expired.proof.checks[3].status, @moonpermit.ProofCheckStatus::Pass)
  assert_eq(expired.proof.checks[4].status, @moonpermit.ProofCheckStatus::Pass)

  let call_runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("proof-calls", [
      @moonpermit.effect_request(effect, @moonpermit.budget(max_calls=1)),
    ]),
  )
  ignore(call_runtime.check("consume", effect, 0L))
  let no_calls = call_runtime.check_with_proof("no-calls", effect, 1L)
  assert_eq(
    no_calls.receipt.reason,
    @moonpermit.ReasonCode::CallBudgetExhausted,
  )
  assert_eq(no_calls.proof.checks[3].status, @moonpermit.ProofCheckStatus::Fail)

  let byte_runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("proof-bytes", [
      @moonpermit.effect_request(
        effect,
        @moonpermit.budget(max_calls=2, max_bytes=3L),
      ),
    ]),
  )
  let no_bytes = byte_runtime.check_with_proof(
    "no-bytes",
    effect,
    0L,
    byte_cost=4L,
  )
  assert_eq(
    no_bytes.receipt.reason,
    @moonpermit.ReasonCode::ByteBudgetExhausted,
  )
  assert_eq(no_bytes.proof.checks[4].status, @moonpermit.ProofCheckStatus::Fail)
  assert_eq(
    byte_runtime.remaining_budget("grant-1").unwrap().max_calls(),
    Some(2),
  )
}
