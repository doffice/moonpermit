///|
fn event_audit_fixture() -> (@moonpermit.Permit, @moonpermit.Runtime) raise {
  let permit = @moonpermit.compile_plan("audit-parent", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=2, max_bytes=20L, expires_at=10L),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  ignore(
    runtime.delegate(
      "audit-child",
      [
        @moonpermit.effect_request(
          @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
          @moonpermit.budget(max_calls=1, max_bytes=8L, expires_at=9L),
        ),
      ],
      0L,
    ),
  )
  ignore(
    runtime.check(
      "parent-read",
      @moonpermit.FileRead(@moonpermit.path_exact("docs/other.md")),
      1L,
      byte_cost=4L,
    ),
  )
  (permit, runtime)
}

///|
fn event_audit_has_issue(
  report : @moonpermit.AuditReport,
  code : @moonpermit.AuditIssueCode,
) -> Bool {
  report.findings().any(finding => finding.code == code)
}

///|
test "event audit replays delegated calls and bytes before a parent check" {
  let (permit, runtime) = event_audit_fixture()
  let receipts = runtime.receipts()
  assert_eq(receipts.length(), 1)
  assert_eq(receipts[0].sequence, 1)
  assert_eq(receipts[0].remaining_calls, Some(0))
  assert_eq(receipts[0].remaining_bytes, Some(8L))
  let report = @moonpermit.audit_events(permit, runtime.events())
  assert_true(report.passed())
  assert_eq(report.checked(), 2)
  // Check-only replay cannot account for the earlier reservation.
  assert_false(@moonpermit.audit_receipts(permit, receipts).passed())
}

///|
test "event audit preserves mixed checks delegations and denials" {
  let effect = @moonpermit.FileWrite(@moonpermit.path_exact("report.json"))
  let permit = @moonpermit.compile_plan("mixed", [
    @moonpermit.effect_request(
      effect,
      @moonpermit.budget(max_calls=4, max_bytes=40L, expires_at=10L),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  assert_true(runtime.check("before", effect, 0L, byte_cost=5L).allowed())
  let child = runtime.delegate(
    "mixed-child",
    [
      @moonpermit.effect_request(
        effect,
        @moonpermit.budget(max_calls=1, max_bytes=10L, expires_at=9L),
      ),
    ],
    1L,
  )
  assert_true(runtime.check("after", effect, 2L, byte_cost=25L).allowed())
  assert_eq(
    runtime.check("bytes-exhausted", effect, 3L, byte_cost=1L).reason,
    @moonpermit.ReasonCode::ByteBudgetExhausted,
  )
  assert_eq(
    runtime.check("after", effect, 4L).reason,
    @moonpermit.ReasonCode::DuplicateInvocation,
  )
  assert_eq(runtime.events().length(), 5)
  assert_true(@moonpermit.audit_events(permit, runtime.events()).passed())
  let child_runtime = @moonpermit.runtime(child)
  assert_true(child_runtime.check("child-write", effect, 2L).allowed())
  assert_true(@moonpermit.audit_events(child, child_runtime.events()).passed())
}

///|
test "failed multi-grant delegation leaves counters and evidence unchanged" {
  let effect = @moonpermit.FileRead(@moonpermit.path_tree("docs"))
  let permit = @moonpermit.compile_plan("rollback-parent", [
    @moonpermit.effect_request(
      effect,
      @moonpermit.budget(max_calls=3, max_bytes=20L, expires_at=10L),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  ignore(runtime.check("before", effect, 0L, byte_cost=4L))
  let before_events = runtime.events()
  let before_budget = runtime.remaining_budget("grant-1")
  try
    ignore(
      runtime.delegate(
        "rejected-child",
        [
          @moonpermit.effect_request(
            @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
            @moonpermit.budget(max_calls=1, max_bytes=1L, expires_at=9L),
          ),
          @moonpermit.effect_request(
            @moonpermit.SecretRead("outside-parent"),
            @moonpermit.budget(max_calls=1),
          ),
        ],
        2L,
      ),
    )
  catch {
    @moonpermit.PermitError::ChildAuthorityExceeded(_) => ()
    _ => fail("expected rejected delegation")
  } noraise {
    _ => fail("unsupported child grant must reject the transaction")
  }
  assert_eq(runtime.remaining_budget("grant-1"), before_budget)
  assert_eq(runtime.events(), before_events)
  assert_true(@moonpermit.audit_events(permit, runtime.events()).passed())
}

///|
test "event audit detects reordered omitted duplicated and renumbered evidence" {
  let (permit, runtime) = event_audit_fixture()
  let events = runtime.events()
  let reordered = [{ ..events[1], sequence: 1, }, { ..events[0], sequence: 2, }]
  let omitted = [{ ..events[1], sequence: 1, }]
  let duplicated = events + [{ ..events[0], sequence: 3, }]
  let wrong_sequence = [{ ..events[0], sequence: 8, }, events[1]]
  for stream in [reordered, omitted, duplicated] {
    assert_false(@moonpermit.audit_events(permit, stream).passed())
  }
  assert_true(
    event_audit_has_issue(
      @moonpermit.audit_events(permit, wrong_sequence),
      @moonpermit.AuditIssueCode::SequenceMismatch,
    ),
  )
}

///|
test "event audit rejects altered reservation snapshots and parent bindings" {
  let (permit, runtime) = event_audit_fixture()
  let events = runtime.events()
  let delegation = match events[0].kind {
    @moonpermit.AuditEventKind::Delegated(value) => value
    _ => fail("expected delegation event")
  }
  let altered = {
    ..events[0],
    kind: @moonpermit.AuditEventKind::Delegated({
      ..delegation,
      remaining_budgets: [@moonpermit.unlimited_budget()],
    }),
  }
  let wrong_parent = {
    ..events[0],
    kind: @moonpermit.AuditEventKind::Delegated({
      ..delegation,
      parent_permit_id: "another-parent",
    }),
  }
  assert_true(
    event_audit_has_issue(
      @moonpermit.audit_events(permit, [altered, events[1]]),
      @moonpermit.AuditIssueCode::ReplayMismatch,
    ),
  )
  assert_true(
    event_audit_has_issue(
      @moonpermit.audit_events(permit, [wrong_parent, events[1]]),
      @moonpermit.AuditIssueCode::PermitMismatch,
    ),
  )
}

///|
test "event audit rejects unsupported children and invalid delegation time" {
  let (permit, runtime) = event_audit_fixture()
  let events = runtime.events()
  let delegation = match events[0].kind {
    @moonpermit.AuditEventKind::Delegated(value) => value
    _ => fail("expected delegation event")
  }
  let outside = @moonpermit.compile_plan("audit-child", [
    @moonpermit.effect_request(
      @moonpermit.SecretRead("outside-parent"),
      @moonpermit.budget(max_calls=1),
    ),
  ])
  let wrong_child = {
    ..events[0],
    kind: @moonpermit.AuditEventKind::Delegated({
      ..delegation,
      child: outside,
    }),
  }
  let wrong_time = {
    ..events[0],
    kind: @moonpermit.AuditEventKind::Delegated({
      ..delegation,
      logical_time: -1L,
    }),
  }
  for event in [wrong_child, wrong_time] {
    assert_true(
      event_audit_has_issue(
        @moonpermit.audit_events(permit, [event]),
        @moonpermit.AuditIssueCode::InvalidReceipt,
      ),
    )
  }
}

///|
test "event audit rejects altered check inputs and receipts" {
  let (permit, runtime) = event_audit_fixture()
  let events = runtime.events()
  let receipt = runtime.receipts()[0]
  let changed = {
    ..events[1],
    kind: @moonpermit.AuditEventKind::Checked({ ..receipt, byte_cost: 5L, }),
  }
  let invalid = {
    ..events[1],
    kind: @moonpermit.AuditEventKind::Checked({ ..receipt, invocation_id: "", }),
  }
  assert_true(
    event_audit_has_issue(
      @moonpermit.audit_events(permit, [events[0], changed]),
      @moonpermit.AuditIssueCode::ReplayMismatch,
    ),
  )
  assert_true(
    event_audit_has_issue(
      @moonpermit.audit_events(permit, [events[0], invalid]),
      @moonpermit.AuditIssueCode::InvalidReceipt,
    ),
  )
}

///|
test "event snapshots do not expose the stored reservation array" {
  let (permit, runtime) = event_audit_fixture()
  let original = runtime.events()
  let snapshot = runtime.events()
  match snapshot[0].kind {
    @moonpermit.AuditEventKind::Delegated(delegation) =>
      delegation.remaining_budgets[0] = @moonpermit.unlimited_budget()
    _ => fail("expected delegation event")
  }
  snapshot[0] = snapshot[1]
  assert_eq(runtime.events(), original)
  assert_true(@moonpermit.audit_events(permit, runtime.events()).passed())
}

///|
test "empty event stream passes with zero examined entries" {
  let (permit, _) = event_audit_fixture()
  let report = @moonpermit.audit_events(permit, [])
  assert_true(report.passed())
  assert_eq(report.checked(), 0)
}
