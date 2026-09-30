///|
fn main raise {
  let permit = @moonpermit.compile_plan("example-docs", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=2),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  ignore(
    runtime.delegate(
      "example-child",
      [
        @moonpermit.effect_request(
          @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
          @moonpermit.budget(max_calls=1),
        ),
      ],
      0L,
    ),
  )
  let allowed = runtime.check(
    "example-1",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    1L,
  )
  let exhausted = runtime.check(
    "example-2",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/other.md")),
    2L,
  )
  let audit = @moonpermit.audit_events(permit, runtime.events())
  println(
    "allowed=" +
    allowed.allowed().to_string() +
    " exhausted=" +
    (!exhausted.allowed()).to_string() +
    " audit=" +
    audit.passed().to_string(),
  )
}
