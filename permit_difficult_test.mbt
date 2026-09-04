///|
test "invalid budgets and empty plans fail closed" {
  try @moonpermit.budget(max_calls=0) catch {
    _ => ()
  } noraise {
    _ => fail("zero call limit should be rejected")
  }
  try @moonpermit.budget(max_bytes=-1L) catch {
    _ => ()
  } noraise {
    _ => fail("negative byte limit should be rejected")
  }
  try @moonpermit.compile_plan("empty", []) catch {
    _ => ()
  } noraise {
    _ => fail("empty plan should be rejected")
  }
}

///|
test "duplicate effects merge to the least common budget ceiling" {
  let effect = @moonpermit.FileWrite(@moonpermit.path_exact("README.md"))
  let first = @moonpermit.effect_request(
    effect,
    @moonpermit.budget(max_calls=1, max_bytes=20L, expires_at=50L),
  )
  let second = @moonpermit.effect_request(
    effect,
    @moonpermit.budget(max_calls=2, max_bytes=10L, expires_at=60L),
  )
  let permit = @moonpermit.compile_plan("merge", [first, second])
  let grants = permit.grants()
  assert_eq(grants.length(), 1)
  assert_eq(grants[0].budget().max_calls(), Some(2))
  assert_eq(grants[0].budget().max_bytes(), Some(20L))
  assert_eq(grants[0].budget().expires_at(), Some(60L))
}
