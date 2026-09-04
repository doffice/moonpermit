///|
test "plan compilation is deterministic and removes exact duplicates" {
  let read = @moonpermit.effect_request(
    @moonpermit.FileRead(@moonpermit.path_tree("src")),
    @moonpermit.budget(max_calls=10),
  )
  let run = @moonpermit.effect_request(
    @moonpermit.ProcessExec(
      @moonpermit.command_exact("moon", ["test", "--deny-warn"]),
    ),
    @moonpermit.budget(max_calls=1),
  )
  let first = @moonpermit.compile_plan("demo", [run, read, read])
  let second = @moonpermit.compile_plan("demo", [read, run])
  assert_eq(first.grant_count(), 2)
  assert_eq(first.canonical(), second.canonical())
  assert_eq(first.id(), "demo")
}

///|
test "budget accessors preserve validated limits" {
  let value = @moonpermit.budget(max_calls=3, max_bytes=1024L, expires_at=100L)
  assert_eq(value.max_calls(), Some(3))
  assert_eq(value.max_bytes(), Some(1024L))
  assert_eq(value.expires_at(), Some(100L))
  assert_eq(@moonpermit.unlimited_budget().max_calls(), None)
}
