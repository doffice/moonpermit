///|
test "delegation narrows scope and reserves finite parent budget" {
  let parent = @moonpermit.compile_plan("parent", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=5, max_bytes=100L, expires_at=100L),
    ),
  ])
  let parent_runtime = @moonpermit.runtime(parent)
  let child = parent_runtime.delegate(
    "child",
    [
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
        @moonpermit.budget(max_calls=2, max_bytes=40L, expires_at=80L),
      ),
    ],
    10L,
  )
  assert_true(@moonpermit.permit_contains(parent, child))
  assert_eq(child.id(), "child")
  assert_eq(
    parent_runtime.remaining_budget("grant-1").unwrap().max_calls(),
    Some(3),
  )
  assert_eq(
    parent_runtime.remaining_budget("grant-1").unwrap().max_bytes(),
    Some(60L),
  )
}
