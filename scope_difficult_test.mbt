///|
test "path prefix confusion does not escape a tree" {
  let grant = @moonpermit.path_tree("docs")
  let sibling = @moonpermit.path_exact("docs-private/secret.md")
  let child_tree = @moonpermit.path_tree("docs/api")
  assert_false(@moonpermit.path_contains(grant, sibling))
  assert_true(@moonpermit.path_contains(grant, child_tree))
}

///|
test "effect kinds never authorize one another" {
  let path = @moonpermit.path_exact("README.md")
  let read = @moonpermit.EffectScope::FileRead(path)
  let write = @moonpermit.EffectScope::FileWrite(path)
  assert_true(@moonpermit.effect_contains(read, read) is @moonpermit.Contained)
  assert_true(
    @moonpermit.effect_contains(read, write) is @moonpermit.NotContained(_),
  )
}

///|
test "network host and sensitivity must both attenuate" {
  let broad = @moonpermit.NetworkSend(
    @moonpermit.network_scope(
      @moonpermit.host_and_subdomains("example.com"),
      ["GET", "POST"],
      @moonpermit.DataClass::Internal,
    ),
  )
  let secret = @moonpermit.NetworkSend(
    @moonpermit.network_scope(
      @moonpermit.host_exact("api.example.com"),
      ["POST"],
      @moonpermit.DataClass::Secret,
    ),
  )
  assert_true(
    @moonpermit.effect_contains(broad, secret) is @moonpermit.NotContained(_),
  )
}

///|
test "canonical effects are stable and explicit" {
  let read = @moonpermit.FileRead(@moonpermit.path_tree("src"))
  let run = @moonpermit.ProcessExec(
    @moonpermit.command_exact("moon", ["test", "--deny-warn"]),
  )
  assert_eq(read.canonical(), "fs.read:src/**")
  assert_eq(run.canonical(), "process.exec:moon test --deny-warn")
}
