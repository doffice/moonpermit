///|
test "property: containment is reflexive for representative effects" {
  let effects = [
    @moonpermit.FileRead(@moonpermit.path_tree(".")),
    @moonpermit.FileRead(@moonpermit.path_tree("docs")),
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    @moonpermit.FileWrite(@moonpermit.path_exact("README.md")),
    @moonpermit.ProcessExec(@moonpermit.command_prefix("moon", ["test"])),
    @moonpermit.NetworkSend(
      @moonpermit.network_scope(
        @moonpermit.host_and_subdomains("example.com"),
        ["GET", "POST"],
        @moonpermit.DataClass::Internal,
      ),
    ),
    @moonpermit.SecretRead("token"),
  ]
  for effect in effects {
    assert_true(
      @moonpermit.effect_contains(effect, effect) is @moonpermit.Contained,
    )
  }
}

///|
test "property: path, command, and host containment is transitive" {
  let root = @moonpermit.path_tree(".")
  let docs = @moonpermit.path_tree("docs")
  let file = @moonpermit.path_exact("docs/guide.md")
  assert_true(@moonpermit.path_contains(root, docs))
  assert_true(@moonpermit.path_contains(docs, file))
  assert_true(@moonpermit.path_contains(root, file))

  let command = @moonpermit.command_prefix("moon", [])
  let tests = @moonpermit.command_prefix("moon", ["test"])
  let exact = @moonpermit.command_exact("moon", ["test", "--deny-warn"])
  assert_true(@moonpermit.command_contains(command, tests))
  assert_true(@moonpermit.command_contains(tests, exact))
  assert_true(@moonpermit.command_contains(command, exact))

  let domain = @moonpermit.host_and_subdomains("example.com")
  let api = @moonpermit.host_and_subdomains("api.example.com")
  let exact_host = @moonpermit.host_exact("v1.api.example.com")
  assert_true(@moonpermit.host_contains(domain, api))
  assert_true(@moonpermit.host_contains(api, exact_host))
  assert_true(@moonpermit.host_contains(domain, exact_host))
}

///|
test "property: effect intersection is commutative and a lower bound" {
  let effects = [
    @moonpermit.FileRead(@moonpermit.path_tree(".")),
    @moonpermit.FileRead(@moonpermit.path_tree("docs")),
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    @moonpermit.FileRead(@moonpermit.path_tree("src")),
    @moonpermit.FileWrite(@moonpermit.path_exact("docs/guide.md")),
    @moonpermit.SecretRead("token"),
  ]
  for left in effects {
    for right in effects {
      let forward = @moonpermit.effect_intersection(left, right)
      let reverse = @moonpermit.effect_intersection(right, left)
      assert_eq(forward, reverse)
      match forward {
        Some(common) => {
          assert_true(
            @moonpermit.effect_contains(left, common) is @moonpermit.Contained,
          )
          assert_true(
            @moonpermit.effect_contains(right, common) is @moonpermit.Contained,
          )
        }
        None => ()
      }
    }
  }
}
