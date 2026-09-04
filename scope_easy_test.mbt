///|
test "exact and tree paths normalize deterministically" {
  let exact = @moonpermit.path_exact("docs//./guide.md")
  let tree = @moonpermit.path_tree("docs/")
  assert_eq(exact.canonical(), "docs/guide.md")
  assert_eq(tree.canonical(), "docs/**")
  assert_false(exact.is_tree())
  assert_true(tree.is_tree())
  assert_true(@moonpermit.path_contains(tree, exact))
  assert_false(@moonpermit.path_contains(exact, tree))
}

///|
test "repository root tree covers every valid relative path" {
  let root = @moonpermit.path_tree(".")
  let nested = @moonpermit.path_exact("src/runtime/check.mbt")
  assert_eq(root.canonical(), "**")
  assert_true(@moonpermit.path_contains(root, nested))
}

///|
test "invalid paths fail closed" {
  try @moonpermit.path_exact("docs/../.env") catch {
    _ => ()
  } noraise {
    _ => fail("parent traversal should be rejected")
  }
  try @moonpermit.path_exact("/etc/passwd") catch {
    _ => ()
  } noraise {
    _ => fail("absolute path should be rejected")
  }
  try @moonpermit.path_exact("docs\\secret.txt") catch {
    _ => ()
  } noraise {
    _ => fail("ambiguous separator should be rejected")
  }
}
