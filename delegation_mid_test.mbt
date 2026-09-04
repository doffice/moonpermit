///|
test "delegation rejects resource widening without consuming budget" {
  let parent_runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("parent", [
      @moonpermit.effect_request(
        @moonpermit.FileRead(@moonpermit.path_tree("docs")),
        @moonpermit.budget(max_calls=2),
      ),
    ]),
  )
  try
    ignore(
      parent_runtime.delegate(
        "child",
        [
          @moonpermit.effect_request(
            @moonpermit.FileRead(@moonpermit.path_exact(".env")),
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
    _ => fail("wider child scope should be rejected")
  }
  assert_eq(
    parent_runtime.remaining_budget("grant-1").unwrap().max_calls(),
    Some(2),
  )
}

///|
test "delegation cannot restore already consumed authority" {
  let parent_runtime = @moonpermit.runtime(
    @moonpermit.compile_plan("parent", [
      @moonpermit.effect_request(
        @moonpermit.SecretRead("deploy-token"),
        @moonpermit.budget(max_calls=2),
      ),
    ]),
  )
  ignore(
    parent_runtime.check(
      "parent-use",
      @moonpermit.SecretRead("deploy-token"),
      1L,
    ),
  )
  try
    ignore(
      parent_runtime.delegate(
        "child",
        [
          @moonpermit.effect_request(
            @moonpermit.SecretRead("deploy-token"),
            @moonpermit.budget(max_calls=2),
          ),
        ],
        2L,
      ),
    )
  catch {
    @moonpermit.PermitError::ChildAuthorityExceeded(_) => ()
    _ => fail("expected ChildAuthorityExceeded")
  } noraise {
    _ => fail("consumed calls must not be replenished")
  }
  assert_eq(
    parent_runtime.remaining_budget("grant-1").unwrap().max_calls(),
    Some(1),
  )
}
