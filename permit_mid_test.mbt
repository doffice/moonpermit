///|
test "bounded budgets attenuate but never widen" {
  let parent = @moonpermit.budget(
    max_calls=10,
    max_bytes=4096L,
    expires_at=100L,
  )
  let child = @moonpermit.budget(max_calls=2, max_bytes=512L, expires_at=90L)
  assert_true(@moonpermit.budget_contains(parent, child))
  assert_false(@moonpermit.budget_contains(child, parent))
  assert_true(
    @moonpermit.budget_contains(@moonpermit.unlimited_budget(), parent),
  )
  assert_false(
    @moonpermit.budget_contains(parent, @moonpermit.unlimited_budget()),
  )
}

///|
test "permit containment checks scope and budget together" {
  let broad = @moonpermit.compile_plan("parent", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=10),
    ),
  ])
  let narrow = @moonpermit.compile_plan("child", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
      @moonpermit.budget(max_calls=2),
    ),
  ])
  assert_true(@moonpermit.permit_contains(broad, narrow))
  assert_false(@moonpermit.permit_contains(narrow, broad))
}
