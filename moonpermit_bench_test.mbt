///|
test "bench compile 100 mixed plan entries" (it : @bench.T) {
  let requests : Array[@moonpermit.EffectRequest] = []
  for index in 0..<100 {
    requests.push(
      @moonpermit.effect_request(
        @moonpermit.FileRead(
          @moonpermit.path_exact("docs/generated-\{index % 25}.md"),
        ),
        @moonpermit.budget(max_calls=index % 5 + 1),
      ),
    )
  }
  it.bench(fn() {
    let permit = @moonpermit.compile_plan("bench-plan", requests) catch {
      _ => panic()
    }
    it.keep(permit.grant_count())
  })
}

///|
test "bench 500 authorized runtime checks" (it : @bench.T) {
  let permit = @moonpermit.compile_plan("bench-runtime", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=500),
    ),
  ])
  let effect = @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md"))
  it.bench(fn() {
    let runtime = @moonpermit.runtime(permit)
    for index in 0..<500 {
      ignore(
        runtime.check("bench-\{index}", effect, index.to_int64()) catch {
          _ => panic()
        },
      )
    }
    it.keep(runtime.receipt_count())
  })
}

///|
test "bench audit 500 receipts" (it : @bench.T) {
  let permit = @moonpermit.compile_plan("bench-audit", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=500),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  for index in 0..<500 {
    ignore(
      runtime.check(
        "audit-\{index}",
        @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
        index.to_int64(),
      ),
    )
  }
  let receipts = runtime.receipts()
  it.bench(fn() {
    let report = @moonpermit.audit_receipts(permit, receipts)
    it.keep(report.checked())
  })
}
