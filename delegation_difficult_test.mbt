///|
test "multi-grant delegation is transactional on late failure" {
  let parent_runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("parent", [
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_tree("docs")),
        @moonpermit.budget(max_calls=3),
      ),
    ]),
  )
  try
    ignore(
      parent_runtime.delegate(
        "child",
        [
          @moonpermit.effect_request(
            @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
            @moonpermit.budget(max_calls=2),
          ),
          @moonpermit.effect_request(
            @moonpermit.NetworkSend(
              @moonpermit.network_scope(
                @moonpermit.host_exact("example.com"),
                ["POST"],
                @moonpermit.DataClass::Public,
              ),
            ),
            @moonpermit.budget(max_calls=1),
          ),
        ],
        0L,
      ),
    )
  catch {
    @moonpermit.PermitError::ChildAuthorityExceeded(_) => ()
    _ => fail("expected ChildAuthorityExceeded")
  } noraise {
    _ => fail("unsupported second grant should reject the delegation")
  }
  assert_eq(
    parent_runtime.remaining_budget("grant-1").unwrap().max_calls(),
    Some(3),
  )
}

///|
test "delegation preserves a narrow grant when a broad grant is required" {
  let parent_runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("parent", [
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
        @moonpermit.budget(max_calls=1),
      ),
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_tree("docs")),
        @moonpermit.budget(max_calls=1),
      ),
    ]),
  )
  let child = parent_runtime.delegate(
    "child",
    [
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_tree("docs")),
        @moonpermit.budget(max_calls=1),
      ),
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
        @moonpermit.budget(max_calls=1),
      ),
    ],
    0L,
  )
  assert_eq(child.grant_count(), 2)
  assert_eq(
    parent_runtime.remaining_budget("grant-1").unwrap().max_calls(),
    Some(0),
  )
  assert_eq(
    parent_runtime.remaining_budget("grant-2").unwrap().max_calls(),
    Some(0),
  )
}

///|
test "expired parent grants cannot authorize a child" {
  let parent_runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("parent", [
      @moonpermit.effect_request(
        @moonpermit.SecretRead("deploy-token"),
        @moonpermit.budget(max_calls=1, expires_at=10L),
      ),
    ]),
  )
  try
    ignore(
      parent_runtime.delegate(
        "child",
        [
          @moonpermit.effect_request(
            @moonpermit.SecretRead("deploy-token"),
            @moonpermit.budget(max_calls=1, expires_at=9L),
          ),
        ],
        10L,
      ),
    )
  catch {
    @moonpermit.PermitError::ChildAuthorityExceeded(_) => ()
    _ => fail("expected ChildAuthorityExceeded")
  } noraise {
    _ => fail("expired parent grant should be rejected")
  }
  assert_eq(
    parent_runtime.remaining_budget("grant-1").unwrap().max_calls(),
    Some(1),
  )
}
