///|
test "scope and budget expansion require approval" {
  let approved = @moonpermit.compile_plan("approved", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=2),
    ),
  ])
  let requested = @moonpermit.compile_plan("requested", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=3),
    ),
    @moonpermit.effect_request(
      @moonpermit.SecretRead("deploy-token"),
      @moonpermit.budget(max_calls=1),
    ),
  ])
  let diff = @moonpermit.diff_permits(approved, requested)
  assert_true(diff.requires_approval())
  assert_eq(diff.entries().length(), 2)
  for entry in diff.entries() {
    assert_eq(entry.verdict, @moonpermit.Verdict::NeedsApproval)
    assert_eq(entry.covered_by, None)
  }
  assert_true(diff.render().contains("NEEDS_APPROVAL"))
}

///|
test "diff rendering is deterministic for reordered requests" {
  let approved = @moonpermit.compile_plan("approved", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree(".")),
      @moonpermit.unlimited_budget(),
    ),
  ])
  let read = @moonpermit.effect_request(
    @moonpermit.FileRead(@moonpermit.path_exact("README.md")),
    @moonpermit.budget(max_calls=1),
  )
  let write = @moonpermit.effect_request(
    @moonpermit.FileWrite(@moonpermit.path_exact("README.md")),
    @moonpermit.budget(max_calls=1),
  )
  let first = @moonpermit.compile_plan("target", [read, write])
  let second = @moonpermit.compile_plan("target", [write, read])
  assert_eq(
    @moonpermit.diff_permits(approved, first).render(),
    @moonpermit.diff_permits(approved, second).render(),
  )
}
