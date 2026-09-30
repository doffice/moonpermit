///|
test "CLI effect DSL normalizes supported inputs" {
  assert_eq(
    parse_effect("read-tree:docs//api").canonical(),
    "fs.read:docs/api/**",
  )
  assert_eq(
    parse_effect("exec:moon,test,--deny-warn").canonical(),
    "process.exec:[\"moon\",\"test\",\"--deny-warn\"]",
  )
  assert_eq(
    parse_effect("net:API.EXAMPLE.COM,post+get,internal").canonical(),
    "network.send:api.example.com[GET,POST]<=internal",
  )
}

///|
test "CLI effect DSL rejects unknown expressions" {
  try ignore(parse_effect("shell:curl example.com")) catch {
    _ => ()
  } noraise {
    _ => fail("unknown effect expression should be rejected")
  }
}

///|
fn cli_test_matches(argv : ArrayView[String]) -> @argparse.Matches raise {
  let matches = cli().parse(argv~, env=Map([]))
  guard matches.subcommand is Some((_, child)) else {
    fail("expected parsed subcommand")
  }
  child
}

///|
fn cli_test_receipts(
  argv : ArrayView[String],
) -> Array[@moonpermit.Receipt] raise {
  let receipts : Array[@moonpermit.Receipt] = []
  check_each(cli_test_matches(argv), receipt => receipts.push(receipt))
  receipts
}

///|
test "CLI compile normalizes grants and preserves requested budget" {
  let permit = compile_result(
    cli_test_matches([
      "compile", "cli-test", "--calls", "2", "--bytes", "10", "--expires", "20",
      "read-tree:docs//api", "read-tree:docs/api",
    ]),
  )
  assert_eq(permit.id(), "cli-test")
  assert_eq(permit.grant_count(), 1)
  let grant = permit.grants()[0]
  assert_eq(grant.effect().canonical(), "fs.read:docs/api/**")
  assert_eq(grant.budget().max_calls(), Some(2))
  assert_eq(grant.budget().max_bytes(), Some(10L))
  assert_eq(grant.budget().expires_at(), Some(20L))
}

///|
test "CLI check emits ordered allow exhaustion and scope-denial receipts" {
  let receipts = cli_test_receipts([
    "check", "--calls", "1", "--repeat", "2", "read-tree:docs", "read:docs/a.md",
  ])
  assert_eq(receipts.length(), 2)
  assert_true(receipts[0].allowed())
  assert_eq(receipts[0].sequence, 1)
  assert_eq(receipts[1].sequence, 2)
  assert_eq(receipts[1].reason, @moonpermit.ReasonCode::CallBudgetExhausted)
  let denied = cli_test_receipts(["check", "read-tree:docs", "read:.env"])
  assert_eq(denied[0].reason, @moonpermit.ReasonCode::NoMatchingGrant)
  let byte_limited = cli_test_receipts([
    "check", "--bytes", "3", "--cost", "4", "write:out.json", "write:out.json",
  ])
  assert_eq(byte_limited[0].reason, @moonpermit.ReasonCode::ByteBudgetExhausted)
}

///|
test "CLI explain returns proof for the same decision and logical time" {
  let result = explain_result(
    cli_test_matches([
      "explain", "--calls", "2", "--bytes", "10", "--expires", "20", "--cost", "4",
      "--now", "5", "read-tree:docs", "read:docs/a.md",
    ]),
  )
  assert_true(result.receipt.allowed())
  assert_eq(result.receipt.logical_time, 5L)
  assert_eq(result.receipt.remaining_calls, Some(1))
  assert_eq(result.receipt.remaining_bytes, Some(6L))
  assert_eq(result.proof.sequence, result.receipt.sequence)
  assert_eq(result.proof.reason, @moonpermit.ReasonCode::Granted)
  let expired = explain_result(
    cli_test_matches([
      "explain", "--expires", "5", "--now", "5", "secret:token", "secret:token",
    ]),
  )
  assert_eq(expired.receipt.reason, @moonpermit.ReasonCode::PermitExpired)
}

///|
test "CLI delegate narrows authority and rejects expansion or replenishment" {
  let child = delegate_result(
    cli_test_matches([
      "delegate", "--parent-calls", "2", "--child-calls", "1", "read-tree:docs",
      "read:docs/a.md",
    ]),
  )
  assert_eq(child.id(), "cli-child")
  assert_eq(child.grants()[0].effect().canonical(), "fs.read:docs/a.md")
  assert_eq(child.grants()[0].budget().max_calls(), Some(1))
  for
    argv in [
      ["delegate", "read-tree:docs", "read:.env"],
      [
        "delegate", "--parent-calls", "1", "--child-calls", "2", "read-tree:docs",
        "read:docs/a.md",
      ],
    ] {
    try ignore(delegate_result(cli_test_matches(argv[:]))) catch {
      @moonpermit.PermitError::ChildAuthorityExceeded(_) => ()
      _ => fail("expected ChildAuthorityExceeded")
    } noraise {
      _ => fail("invalid delegation must fail")
    }
  }
}

///|
test "CLI diff distinguishes covered authority from expansion" {
  let covered = diff_result(
    cli_test_matches(["diff", "read-tree:docs", "read:docs/a.md"]),
  )
  let expanded = diff_result(
    cli_test_matches(["diff", "read-tree:docs", "read:.env"]),
  )
  assert_false(covered.requires_approval())
  assert_true(expanded.requires_approval())
  assert_eq(expanded.entries()[0].verdict, @moonpermit.Verdict::NeedsApproval)
}

///|
test "CLI audit includes one delegation and three authorization checks" {
  ignore(cli_test_matches(["audit"]))
  let report = audit_scenario()
  assert_true(report.passed())
  assert_eq(report.checked(), 4)
}

///|
test "CLI defaults and required values are handled by the command parser" {
  let defaults = cli().parse(argv=[], env=Map([]))
  assert_true(defaults.subcommand is Some(("demo", _)))
  for argv in [["compile"], ["check", "read:docs/a.md"], ["unknown"]] {
    try ignore(cli().parse(argv=argv[:], env=Map([]))) catch {
      _ => ()
    } noraise {
      _ => fail("missing arguments or unknown command must fail")
    }
  }
}

///|
test "CLI rejects invalid effect payloads and unsafe scopes" {
  for
    input in [
      "exec:", "net:host", "net:example.com,GET,unknown", "net:example.com,,public",
      "net:bad/host,GET,public", "secret:", "read:../private", "read:/etc/passwd",
    ] {
    try ignore(parse_effect(input)) catch {
      _ => ()
    } noraise {
      _ => fail("invalid effect expression must fail")
    }
  }
  assert_eq(parse_effect("delete:out.json").canonical(), "fs.delete:out.json")
  assert_eq(
    parse_effect("exec-prefix:moon,test").canonical(),
    "process.exec:[\"moon\",\"test\"] ...",
  )
  assert_eq(
    parse_effect("net-tree:EXAMPLE.COM,post,secret").canonical(),
    "network.send:example.com+subdomains[POST]<=secret",
  )
}

///|
test "CLI rejects invalid integers budgets time cost and repeat" {
  for
    argv in [
      ["check", "--calls=zero", "read:docs/a.md", "read:docs/a.md"],
      ["check", "--calls=0", "read:docs/a.md", "read:docs/a.md"],
      ["check", "--bytes=-1", "read:docs/a.md", "read:docs/a.md"],
      ["check", "--expires=-1", "read:docs/a.md", "read:docs/a.md"],
      ["check", "--cost=-1", "read:docs/a.md", "read:docs/a.md"],
      ["check", "--repeat=0", "read:docs/a.md", "read:docs/a.md"],
      ["check", "--repeat=-1", "read:docs/a.md", "read:docs/a.md"],
    ] {
    try ignore(cli_test_receipts(argv[:])) catch {
      _ => ()
    } noraise {
      _ => fail("invalid numeric input must fail")
    }
  }
  try
    ignore(
      explain_result(
        cli_test_matches(["explain", "--now=-1", "secret:token", "secret:token"]),
      ),
    )
  catch {
    @moonpermit.PermitError::InvalidLogicalTime(_) => ()
    _ => fail("expected InvalidLogicalTime")
  } noraise {
    _ => fail("negative time must fail")
  }
}
