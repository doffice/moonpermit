///|
test "equivalent and narrower permits need no additional approval" {
  let approved = @moonpermit.compile_plan("approved", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=5),
    ),
  ])
  let requested = @moonpermit.compile_plan("requested", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
      @moonpermit.budget(max_calls=2),
    ),
  ])
  let diff = @moonpermit.diff_permits(approved, requested)
  assert_false(diff.requires_approval())
  assert_eq(diff.entries()[0].verdict, @moonpermit.Verdict::Allow)
  assert_eq(diff.entries()[0].covered_by, Some("grant-1"))
}
