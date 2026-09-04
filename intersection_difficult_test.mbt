///|
test "network intersection combines host methods and sensitivity" {
  let left = @moonpermit.NetworkSend(
    @moonpermit.network_scope(
      @moonpermit.host_and_subdomains("example.com"),
      ["GET", "POST"],
      @moonpermit.DataClass::Confidential,
    ),
  )
  let right = @moonpermit.NetworkSend(
    @moonpermit.network_scope(
      @moonpermit.host_exact("api.example.com"),
      ["POST", "DELETE"],
      @moonpermit.DataClass::Internal,
    ),
  )
  let expected = @moonpermit.NetworkSend(
    @moonpermit.network_scope(
      @moonpermit.host_exact("api.example.com"),
      ["POST"],
      @moonpermit.DataClass::Internal,
    ),
  )
  assert_eq(@moonpermit.effect_intersection(left, right), Some(expected))
}

///|
test "disjoint resources and effect kinds have no intersection" {
  let docs = @moonpermit.FileRead(@moonpermit.path_tree("docs"))
  let source = @moonpermit.FileRead(@moonpermit.path_tree("src"))
  let write = @moonpermit.FileWrite(@moonpermit.path_tree("docs"))
  assert_eq(@moonpermit.effect_intersection(docs, source), None)
  assert_eq(@moonpermit.effect_intersection(docs, write), None)
}

///|
test "network scopes with no common method are disjoint" {
  let get = @moonpermit.NetworkSend(
    @moonpermit.network_scope(
      @moonpermit.host_exact("example.com"),
      ["GET"],
      @moonpermit.DataClass::Public,
    ),
  )
  let post = @moonpermit.NetworkSend(
    @moonpermit.network_scope(
      @moonpermit.host_exact("example.com"),
      ["POST"],
      @moonpermit.DataClass::Public,
    ),
  )
  assert_eq(@moonpermit.effect_intersection(get, post), None)
}
