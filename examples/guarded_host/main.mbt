///|
enum ToolCall {
  ReadFile(String)
  Unsupported(String)
} derive(Eq, Debug)

///|
struct FakeExecutor {
  mut calls : Int
}

///|
fn FakeExecutor::read(self : FakeExecutor, path : String) -> String {
  self.calls = self.calls + 1
  "fixture:" + path
}

///|
struct GuardedHost {
  runtime : @moonpermit.Runtime
  executor : FakeExecutor
  decisions : Array[@moonpermit.CheckedAuthorization]
}

///|
fn guarded_host(permit : @moonpermit.Permit) -> GuardedHost {
  {
    runtime: @moonpermit.runtime(permit),
    executor: { calls: 0, },
    decisions: [],
  }
}

///|
fn GuardedHost::invoke(
  self : GuardedHost,
  invocation_id : String,
  call : ToolCall,
  logical_time : Int64,
  byte_cost : Int64,
) -> String raise {
  match call {
    Unsupported(name) => "DENY unsupported:" + name + " executed=false"
    ReadFile(path) => {
      let requested = @moonpermit.FileRead(@moonpermit.path_exact(path))
      let checked = self.runtime.check_with_proof(
        invocation_id,
        requested,
        logical_time,
        byte_cost~,
      )
      self.decisions.push(checked)
      if checked.receipt.allowed() {
        let value = self.executor.read(path)
        "ALLOW " +
        checked.receipt.reason.to_json().stringify() +
        " executed=true value=" +
        value
      } else {
        "DENY " +
        checked.receipt.reason.to_json().stringify() +
        " executed=false"
      }
    }
  }
}

///|
fn demo_lines() -> Array[String] raise {
  let permit = @moonpermit.compile_plan("guarded-host", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=1, max_bytes=64L, expires_at=10L),
    ),
  ])
  let host = guarded_host(permit)
  let lines = [
    host.invoke("read-1", ReadFile("docs/guide.md"), 1L, 16L),
    host.invoke("read-2", ReadFile("docs/other.md"), 2L, 8L),
    host.invoke("outside-1", ReadFile(".env"), 3L, 4L),
    host.invoke("read-1", ReadFile("docs/guide.md"), 4L, 16L),
    host.invoke("unknown-1", Unsupported("shell"), 5L, 0L),
  ]
  let requested = @moonpermit.compile_plan("expanded-host", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=1, max_bytes=64L, expires_at=10L),
    ),
    @moonpermit.effect_request(
      @moonpermit.NetworkSend(
        @moonpermit.network_scope(
          @moonpermit.host_exact("api.example.com"),
          ["POST"],
          @moonpermit.DataClass::Public,
        ),
      ),
      @moonpermit.budget(max_calls=1, max_bytes=32L),
    ),
  ])
  let diff = @moonpermit.diff_permits(permit, requested)
  lines.push("needs_approval=" + diff.requires_approval().to_string())
  let audit = @moonpermit.audit_receipts(permit, host.runtime.receipts())
  lines.push(
    "audit=" +
    audit.passed().to_string() +
    " checked=" +
    audit.checked().to_string() +
    " executor_calls=" +
    host.executor.calls.to_string(),
  )
  lines
}

///|
fn main raise {
  for line in demo_lines() {
    println(line)
  }
}
