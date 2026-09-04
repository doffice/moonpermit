///|
test "CLI effect DSL normalizes supported inputs" {
  assert_eq(
    parse_effect("read-tree:docs//api").canonical(),
    "fs.read:docs/api/**",
  )
  assert_eq(
    parse_effect("exec:moon,test,--deny-warn").canonical(),
    "process.exec:moon test --deny-warn",
  )
  assert_eq(
    parse_effect("net:API.EXAMPLE.COM,post+get,internal").canonical(),
    "network.send:api.example.com[GET,POST]<=internal",
  )
}

///|
test "CLI effect DSL rejects unknown expressions" {
  try ignore(parse_effect("shell:curl example.com")) catch {
    _ => ()
  } noraise {
    _ => fail("unknown effect expression should be rejected")
  }
}
