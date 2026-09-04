///|
test "validation rejects empty and malformed scope components" {
  try @moonpermit.path_exact("") catch {
    @moonpermit.ScopeError::EmptyPath => ()
    _ => fail("expected EmptyPath")
  } noraise {
    _ => fail("empty path should fail")
  }
  try @moonpermit.command_exact("  ", []) catch {
    @moonpermit.ScopeError::EmptyProgram => ()
    _ => fail("expected EmptyProgram")
  } noraise {
    _ => fail("empty program should fail")
  }
  for host in ["", "bad_host.example", "-bad.example"] {
    try @moonpermit.host_exact(host) catch {
      @moonpermit.ScopeError::InvalidHost(_) => ()
      _ => fail("expected InvalidHost")
    } noraise {
      _ => fail("malformed host should fail")
    }
  }
  try
    ignore(
      @moonpermit.network_scope(
        @moonpermit.host_exact("example.com"),
        [],
        @moonpermit.DataClass::Public,
      ),
    )
  catch {
    @moonpermit.ScopeError::EmptyMethodSet => ()
    _ => fail("expected EmptyMethodSet")
  } noraise {
    _ => fail("empty method set should fail")
  }
  for http_method in ["", "GET1"] {
    try
      ignore(
        @moonpermit.network_scope(
          @moonpermit.host_exact("example.com"),
          [http_method],
          @moonpermit.DataClass::Public,
        ),
      )
    catch {
      @moonpermit.ScopeError::InvalidMethod(_) => ()
      _ => fail("expected InvalidMethod")
    } noraise {
      _ => fail("malformed method should fail")
    }
  }
}

///|
test "command and network negative branches stay fail closed" {
  let exact = @moonpermit.command_exact("moon", ["test"])
  let prefix = @moonpermit.command_prefix("moon", ["test"])
  assert_eq(exact.program(), "moon")
  assert_eq(exact.arguments(), ["test"])
  assert_false(exact.allows_extra_arguments())
  assert_true(prefix.allows_extra_arguments())
  assert_false(
    @moonpermit.command_contains(
      exact,
      @moonpermit.command_exact("node", ["test"]),
    ),
  )
  assert_false(
    @moonpermit.command_contains(
      prefix,
      @moonpermit.command_exact("moon", ["build"]),
    ),
  )
  assert_false(@moonpermit.command_contains(exact, prefix))
  assert_eq(
    @moonpermit.ProcessExec(prefix).canonical(),
    "process.exec:moon test ...",
  )
  let broad_host = @moonpermit.host_and_subdomains("example.com")
  assert_true(broad_host.includes_subdomains())
  let get = @moonpermit.network_scope(
    broad_host,
    ["GET"],
    @moonpermit.DataClass::Secret,
  )
  let post = @moonpermit.network_scope(
    @moonpermit.host_exact("api.example.com"),
    ["POST"],
    @moonpermit.DataClass::Confidential,
  )
  assert_false(@moonpermit.network_contains(get, post))
  assert_eq(
    @moonpermit.NetworkSend(get).canonical(),
    "network.send:example.com+subdomains[GET]<=secret",
  )
}

///|
test "unbounded budgets and public accessors preserve their semantics" {
  let effect = @moonpermit.FileDelete(@moonpermit.path_exact("tmp.txt"))
  let limited = @moonpermit.effect_request(
    effect,
    @moonpermit.budget(max_calls=1, max_bytes=8L, expires_at=10L),
  )
  let unlimited = @moonpermit.effect_request(
    effect,
    @moonpermit.unlimited_budget(),
  )
  assert_false(
    @moonpermit.budget_contains(limited.budget(), unlimited.budget()),
  )
  let permit = @moonpermit.compile_plan("merged", [limited, unlimited])
  let grant = permit.grants()[0]
  assert_eq(grant.id(), "grant-1")
  assert_eq(grant.effect(), effect)
  assert_eq(grant.budget().max_calls(), None)
  assert_eq(grant.budget().max_bytes(), None)
  assert_true(permit.canonical().contains("calls=*;bytes=*;expires=*"))
  assert_eq(effect.canonical(), "fs.delete:tmp.txt")
  assert_eq(@moonpermit.SecretRead("").canonical(), "secret.read:<invalid>")
  try @moonpermit.compile_plan("  ", [limited]) catch {
    @moonpermit.PermitError::EmptyPermitId => ()
    _ => fail("expected EmptyPermitId")
  } noraise {
    _ => fail("empty permit identifier should fail")
  }
}

///|
test "remaining intersection branches are symmetric and disjoint" {
  let exact_command = @moonpermit.ProcessExec(
    @moonpermit.command_exact("moon", ["test", "--deny-warn"]),
  )
  let prefix_command = @moonpermit.ProcessExec(
    @moonpermit.command_prefix("moon", ["test"]),
  )
  assert_eq(
    @moonpermit.effect_intersection(exact_command, prefix_command),
    Some(exact_command),
  )
  assert_eq(
    @moonpermit.effect_intersection(
      exact_command,
      @moonpermit.ProcessExec(@moonpermit.command_exact("node", ["test"])),
    ),
    None,
  )
  let delete = @moonpermit.FileDelete(@moonpermit.path_tree("tmp"))
  assert_eq(@moonpermit.effect_intersection(delete, delete), Some(delete))
  assert_eq(
    @moonpermit.effect_intersection(
      @moonpermit.SecretRead("a"),
      @moonpermit.SecretRead("b"),
    ),
    None,
  )
  let left = @moonpermit.budget(max_calls=2, max_bytes=8L, expires_at=20L)
  let right = @moonpermit.budget(max_calls=3, max_bytes=5L, expires_at=10L)
  let common = @moonpermit.budget_intersection(left, right)
  assert_eq(common.max_calls(), Some(2))
  assert_eq(common.max_bytes(), Some(5L))
  assert_eq(common.expires_at(), Some(10L))
}

///|
test "unlimited runtime, invalid audit input, and delegation edges are visible" {
  let permit = @moonpermit.compile_plan("unlimited", [
    @moonpermit.effect_request(
      @moonpermit.SecretRead("token"),
      @moonpermit.unlimited_budget(),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  assert_eq(runtime.permit_id(), "unlimited")
  let receipt = runtime.check("first", @moonpermit.SecretRead("token"), 0L)
  assert_true(receipt.allowed())
  assert_eq(receipt.remaining_calls, None)
  assert_eq(receipt.remaining_bytes, None)
  let invalid = { ..receipt, invocation_id: "", }
  let report = @moonpermit.audit_receipts(permit, [invalid])
  assert_true(
    report
    .findings()
    .any(finding => finding.code is @moonpermit.AuditIssueCode::InvalidReceipt),
  )
  let child = runtime.delegate(
    "finite-child",
    [
      @moonpermit.effect_request(
        @moonpermit.SecretRead("token"),
        @moonpermit.budget(max_calls=1),
      ),
    ],
    1L,
  )
  assert_eq(child.grant_count(), 1)
  assert_eq(runtime.remaining_budget("grant-1").unwrap().max_calls(), None)
  try
    ignore(
      runtime.delegate(
        "invalid-time",
        [
          @moonpermit.effect_request(
            @moonpermit.SecretRead("token"),
            @moonpermit.budget(max_calls=1),
          ),
        ],
        -1L,
      ),
    )
  catch {
    @moonpermit.PermitError::InvalidLogicalTime(-1L) => ()
    _ => fail("expected InvalidLogicalTime")
  } noraise {
    _ => fail("negative delegation time should fail")
  }
}
