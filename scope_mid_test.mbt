///|
test "command prefixes attenuate by adding fixed arguments" {
  let grant = @moonpermit.command_prefix("moon", ["test"])
  let exact = @moonpermit.command_exact("moon", ["test", "scope_easy_test.mbt"])
  let wider = @moonpermit.command_prefix("moon", [])
  assert_true(@moonpermit.command_contains(grant, exact))
  assert_false(@moonpermit.command_contains(exact, grant))
  assert_false(@moonpermit.command_contains(grant, wider))
  assert_eq(exact.program(), "moon")
  assert_eq(exact.arguments(), ["test", "scope_easy_test.mbt"])
  assert_false(exact.allows_extra_arguments())
}

///|
test "host scopes use DNS label boundaries" {
  let grant = @moonpermit.host_and_subdomains("API.Example.COM.")
  let child = @moonpermit.host_exact("v1.api.example.com")
  let confusion = @moonpermit.host_exact("evil-api.example.com")
  assert_eq(grant.canonical(), "api.example.com")
  assert_true(@moonpermit.host_contains(grant, child))
  assert_false(@moonpermit.host_contains(grant, confusion))
}

///|
test "network scope narrows methods and data class" {
  let host = @moonpermit.host_and_subdomains("example.com")
  let broad = @moonpermit.network_scope(
    host,
    ["post", "GET", "GET"],
    @moonpermit.DataClass::Confidential,
  )
  let narrow = @moonpermit.network_scope(
    @moonpermit.host_exact("api.example.com"),
    ["GET"],
    @moonpermit.DataClass::Public,
  )
  assert_true(@moonpermit.network_contains(broad, narrow))
  assert_false(@moonpermit.network_contains(narrow, broad))
}
