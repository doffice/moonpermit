///|
test "path and command intersections select the narrower scope" {
  let tree = @moonpermit.FileRead(@moonpermit.path_tree("docs"))
  let exact = @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md"))
  assert_eq(@moonpermit.effect_intersection(tree, exact), Some(exact))
  let prefix = @moonpermit.ProcessExec(
    @moonpermit.command_prefix("moon", ["test"]),
  )
  let invocation = @moonpermit.ProcessExec(
    @moonpermit.command_exact("moon", ["test", "--deny-warn"]),
  )
  assert_eq(
    @moonpermit.effect_intersection(prefix, invocation),
    Some(invocation),
  )
}

///|
test "budget intersection takes every tighter finite constraint" {
  let left = @moonpermit.budget(max_calls=5, expires_at=100L)
  let right = @moonpermit.budget(max_calls=3, max_bytes=20L)
  let common = @moonpermit.budget_intersection(left, right)
  assert_eq(common.max_calls(), Some(3))
  assert_eq(common.max_bytes(), Some(20L))
  assert_eq(common.expires_at(), Some(100L))
}
