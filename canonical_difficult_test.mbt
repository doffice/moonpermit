///|
test "command canonical form preserves spaces empty arguments and escaping" {
  let effects = [
    @moonpermit.ProcessExec(@moonpermit.command_exact("tool", ["a b", "c"])),
    @moonpermit.ProcessExec(@moonpermit.command_exact("tool", ["a", "b c"])),
    @moonpermit.ProcessExec(@moonpermit.command_exact("tool", [])),
    @moonpermit.ProcessExec(@moonpermit.command_exact("tool", [""])),
    @moonpermit.ProcessExec(@moonpermit.command_exact("tool name", ["a"])),
    @moonpermit.ProcessExec(@moonpermit.command_exact("tool", ["name a"])),
    @moonpermit.ProcessExec(@moonpermit.command_exact("tool", ["a\"b\\c"])),
    @moonpermit.ProcessExec(@moonpermit.command_prefix("tool", ["a b", "c"])),
  ]
  for index, left in effects {
    for other in (index + 1)..<effects.length() {
      assert_false(left.canonical() == effects[other].canonical())
    }
  }
  assert_eq(effects[0].canonical(), "process.exec:[\"tool\",\"a b\",\"c\"]")
  assert_eq(effects[3].canonical(), "process.exec:[\"tool\",\"\"]")
}

///|
test "space-bearing command plans and receipts are independent of input order" {
  let first = @moonpermit.ProcessExec(
    @moonpermit.command_exact("tool", ["a b", "c"]),
  )
  let second = @moonpermit.ProcessExec(
    @moonpermit.command_exact("tool", ["a", "b c"]),
  )
  let a = @moonpermit.effect_request(first, @moonpermit.budget(max_calls=1))
  let b = @moonpermit.effect_request(second, @moonpermit.budget(max_calls=2))
  let forward = @moonpermit.compile_plan("commands", [a, b])
  let backward = @moonpermit.compile_plan("commands", [b, a])
  assert_eq(forward, backward)
  assert_eq(forward.to_json().stringify(), backward.to_json().stringify())
  let left = @moonpermit.runtime(forward)
  let right = @moonpermit.runtime(backward)
  for index, effect in [first, second] {
    let id = "command-\{index}"
    let l = left.check_with_proof(id, effect, 0L)
    let r = right.check_with_proof(id, effect, 0L)
    assert_true(l.receipt.allowed())
    assert_eq(l, r)
  }
  assert_eq(left.events(), right.events())
  assert_true(@moonpermit.audit_events(forward, left.events()).passed())
}
