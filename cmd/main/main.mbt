///|
fn split_owned(input : String, separator : String) -> Array[String] {
  let values : Array[String] = []
  for value in input.split(separator) {
    values.push(value.to_owned())
  }
  values
}

///|
fn parse_data_class(input : String) -> @moonpermit.DataClass raise {
  match input.to_lower() {
    "public" => @moonpermit.DataClass::Public
    "internal" => @moonpermit.DataClass::Internal
    "confidential" => @moonpermit.DataClass::Confidential
    "secret" => @moonpermit.DataClass::Secret
    _ => raise Failure("unknown data class: " + input)
  }
}

///|
fn parse_command_payload(
  payload : String,
  allow_extra_arguments : Bool,
) -> @moonpermit.EffectScope raise {
  let parts = split_owned(payload, ",")
  if parts.is_empty() {
    raise Failure("an executable is required")
  }
  let arguments : Array[String] = []
  for index in 1..<parts.length() {
    arguments.push(parts[index])
  }
  if allow_extra_arguments {
    @moonpermit.ProcessExec(@moonpermit.command_prefix(parts[0], arguments))
  } else {
    @moonpermit.ProcessExec(@moonpermit.command_exact(parts[0], arguments))
  }
}

///|
fn parse_network_payload(
  payload : String,
  include_subdomains : Bool,
) -> @moonpermit.EffectScope raise {
  let parts = split_owned(payload, ",")
  if parts.length() != 3 {
    raise Failure("network effect requires host, METHOD+METHOD, data-class")
  }
  let methods = split_owned(parts[1], "+")
  let host = if include_subdomains {
    @moonpermit.host_and_subdomains(parts[0])
  } else {
    @moonpermit.host_exact(parts[0])
  }
  @moonpermit.NetworkSend(
    @moonpermit.network_scope(host, methods, parse_data_class(parts[2])),
  )
}

///|
fn parse_effect(input : String) -> @moonpermit.EffectScope raise {
  match input.strip_prefix("read-tree:") {
    Some(path) =>
      return @moonpermit.FileRead(@moonpermit.path_tree(path.to_owned()))
    None => ()
  }
  match input.strip_prefix("read:") {
    Some(path) =>
      return @moonpermit.FileRead(@moonpermit.path_exact(path.to_owned()))
    None => ()
  }
  match input.strip_prefix("write:") {
    Some(path) =>
      return @moonpermit.FileWrite(@moonpermit.path_exact(path.to_owned()))
    None => ()
  }
  match input.strip_prefix("delete:") {
    Some(path) =>
      return @moonpermit.FileDelete(@moonpermit.path_exact(path.to_owned()))
    None => ()
  }
  match input.strip_prefix("exec-prefix:") {
    Some(command) => return parse_command_payload(command.to_owned(), true)
    None => ()
  }
  match input.strip_prefix("exec:") {
    Some(command) => return parse_command_payload(command.to_owned(), false)
    None => ()
  }
  match input.strip_prefix("net-tree:") {
    Some(network) => return parse_network_payload(network.to_owned(), true)
    None => ()
  }
  match input.strip_prefix("net:") {
    Some(network) => return parse_network_payload(network.to_owned(), false)
    None => ()
  }
  match input.strip_prefix("secret:") {
    Some(name) => {
      let secret_name = name.to_owned()
      if secret_name is "" {
        raise Failure("secret identifier cannot be empty")
      }
      return @moonpermit.SecretRead(secret_name)
    }
    None => ()
  }
  raise Failure("unknown effect expression: " + input)
}

///|
fn values(matches : @argparse.Matches, name : String) -> Array[String] raise {
  match matches.values.get(name) {
    Some(values) if !values.is_empty() => values
    _ => raise Failure("missing CLI value: " + name)
  }
}

///|
fn value(matches : @argparse.Matches, name : String) -> String raise {
  values(matches, name)[0]
}

///|
fn optional_value(matches : @argparse.Matches, name : String) -> String? {
  match matches.values.get(name) {
    Some(values) if !values.is_empty() => Some(values[0])
    _ => None
  }
}

///|
fn parse_optional_int(matches : @argparse.Matches, name : String) -> Int? raise {
  match optional_value(matches, name) {
    Some(text) => Some(@string.from_str(text))
    None => None
  }
}

///|
fn parse_optional_int64(
  matches : @argparse.Matches,
  name : String,
) -> Int64? raise {
  match optional_value(matches, name) {
    Some(text) => Some(@string.from_str(text))
    None => None
  }
}

///|
fn parse_budget(matches : @argparse.Matches) -> @moonpermit.Budget raise {
  let max_calls = parse_optional_int(matches, "calls")
  let max_bytes = parse_optional_int64(matches, "bytes")
  let expires_at = parse_optional_int64(matches, "expires")
  @moonpermit.budget(max_calls?, max_bytes?, expires_at?)
}

///|
fn parse_requests(
  matches : @argparse.Matches,
) -> Array[@moonpermit.EffectRequest] raise {
  let request_budget = parse_budget(matches)
  values(matches, "effects").map(effect => {
    @moonpermit.effect_request(parse_effect(effect), request_budget)
  })
}

///|
fn[T : ToJson] print_json(value : T) -> Unit {
  println(value.to_json().stringify())
}

///|
fn run_compile(matches : @argparse.Matches) -> Unit raise {
  let permit = @moonpermit.compile_plan(
    value(matches, "permit-id"),
    parse_requests(matches),
  )
  print_json(permit)
}

///|
fn run_check(matches : @argparse.Matches) -> Unit raise {
  let permit = @moonpermit.compile_plan("cli-check", [
    @moonpermit.effect_request(
      parse_effect(value(matches, "approved-effect")),
      parse_budget(matches),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let requested = parse_effect(value(matches, "requested-effect"))
  let byte_cost = parse_optional_int64(matches, "cost").unwrap_or(0L)
  let repeat = parse_optional_int(matches, "repeat").unwrap_or(1)
  for index in 0..<repeat {
    print_json(
      runtime.check(
        "cli-call-\{index + 1}",
        requested,
        index.to_int64(),
        byte_cost~,
      ),
    )
  }
}

///|
fn run_explain(matches : @argparse.Matches) -> Unit raise {
  let permit = @moonpermit.compile_plan("cli-explain", [
    @moonpermit.effect_request(
      parse_effect(value(matches, "approved-effect")),
      parse_budget(matches),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let requested = parse_effect(value(matches, "requested-effect"))
  let byte_cost = parse_optional_int64(matches, "cost").unwrap_or(0L)
  let now = parse_optional_int64(matches, "now").unwrap_or(0L)
  print_json(
    runtime.check_with_proof("cli-explain", requested, now, byte_cost~),
  )
}

///|
fn run_delegate(matches : @argparse.Matches) -> Unit raise {
  let parent = @moonpermit.compile_plan("cli-parent", [
    @moonpermit.effect_request(
      parse_effect(value(matches, "parent-effect")),
      @moonpermit.budget(
        max_calls=parse_optional_int(matches, "parent-calls").unwrap_or(2),
      ),
    ),
  ])
  let parent_runtime = @moonpermit.runtime(parent)
  let child = parent_runtime.delegate(
    "cli-child",
    [
      @moonpermit.effect_request(
        parse_effect(value(matches, "child-effect")),
        @moonpermit.budget(
          max_calls=parse_optional_int(matches, "child-calls").unwrap_or(1),
        ),
      ),
    ],
    0L,
  )
  print_json(child)
}

///|
fn run_diff(matches : @argparse.Matches) -> Unit raise {
  let approved = @moonpermit.compile_plan("cli-approved", [
    @moonpermit.effect_request(
      parse_effect(value(matches, "approved-effect")),
      @moonpermit.budget(max_calls=2),
    ),
  ])
  let requested = @moonpermit.compile_plan("cli-requested", [
    @moonpermit.effect_request(
      parse_effect(value(matches, "requested-effect")),
      @moonpermit.budget(max_calls=2),
    ),
  ])
  println(@moonpermit.diff_permits(approved, requested).render())
}

///|
fn audit_scenario() -> @moonpermit.AuditReport raise {
  let permit = @moonpermit.compile_plan("cli-audit", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=1),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  ignore(
    runtime.check(
      "demo-allow",
      @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
      1L,
    ),
  )
  ignore(
    runtime.check(
      "demo-exhaust",
      @moonpermit.FileRead(@moonpermit.path_exact("docs/other.md")),
      2L,
    ),
  )
  ignore(
    runtime.check(
      "demo-deny",
      @moonpermit.FileRead(@moonpermit.path_exact(".env")),
      3L,
    ),
  )
  @moonpermit.audit_receipts(permit, runtime.receipts())
}

///|
fn run_audit() -> Unit raise {
  print_json(audit_scenario())
}

///|
fn run_demo() -> Unit raise {
  println(
    "MoonPermit demo: proof, allow, deny, exhaustion, expiry, delegation, diff, audit",
  )
  let approved = @moonpermit.compile_plan("demo", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=1),
    ),
  ])
  println(approved.canonical())
  let runtime = @moonpermit.runtime(approved)
  let explained = runtime.check_with_proof(
    "demo-1",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    1L,
  )
  print_json(explained.receipt)
  print_json(explained.proof)
  print_json(
    runtime.check(
      "demo-2",
      @moonpermit.FileRead(@moonpermit.path_exact("docs/other.md")),
      2L,
    ),
  )
  let expiring = @moonpermit.runtime(
    @moonpermit.compile_plan("expiring", [
      @moonpermit.effect_request(
        @moonpermit.SecretRead("demo-token"),
        @moonpermit.budget(max_calls=1, expires_at=5L),
      ),
    ]),
  )
  print_json(
    expiring.check("demo-expired", @moonpermit.SecretRead("demo-token"), 5L),
  )
  try
    ignore(
      runtime.delegate(
        "invalid-child",
        [
          @moonpermit.effect_request(
            @moonpermit.FileRead(@moonpermit.path_exact(".env")),
            @moonpermit.budget(max_calls=1),
          ),
        ],
        3L,
      ),
    )
  catch {
    @moonpermit.PermitError::ChildAuthorityExceeded(_) =>
      println("delegation_expansion=DENIED")
    _ => raise Failure("unexpected delegation failure")
  } noraise {
    _ => raise Failure("delegation expansion was unexpectedly allowed")
  }
  let requested = @moonpermit.compile_plan("expanded", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_exact(".env")),
      @moonpermit.budget(max_calls=1),
    ),
  ])
  println(@moonpermit.diff_permits(approved, requested).render())
  println("audit_passed=" + audit_scenario().passed().to_string())
}

///|
fn budget_options() -> Array[@argparse.OptionArg] {
  [
    @argparse.OptionArg("calls", about="Maximum calls"),
    @argparse.OptionArg("bytes", about="Maximum bytes"),
    @argparse.OptionArg("expires", about="Exclusive logical expiry"),
  ]
}

///|
fn cli() -> @argparse.Command {
  let compile = @argparse.Command(
    "compile",
    about="Compile one or more effect expressions into a permit",
    options=budget_options(),
    positionals=[
      @argparse.PositionArg(
        "permit-id",
        about="Permit identifier",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
      @argparse.PositionArg(
        "effects",
        about="Effect DSL expressions",
        num_args=@argparse.ValueRange(lower=1),
      ),
    ],
  )
  let check = @argparse.Command(
    "check",
    about="Check a requested effect and emit JSONL receipts",
    options=budget_options() +
      [
        @argparse.OptionArg("cost", about="Byte cost", default_values=["0"]),
        @argparse.OptionArg("repeat", about="Invocation count", default_values=[
          "1",
        ]),
      ],
    positionals=[
      @argparse.PositionArg(
        "approved-effect",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
      @argparse.PositionArg(
        "requested-effect",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
    ],
  )
  let explain = @argparse.Command(
    "explain",
    about="Check once and emit a receipt with structured proof as JSON",
    options=budget_options() +
      [
        @argparse.OptionArg("cost", about="Byte cost", default_values=["0"]),
        @argparse.OptionArg("now", about="Explicit logical timestamp", default_values=[
          "0",
        ]),
      ],
    positionals=[
      @argparse.PositionArg(
        "approved-effect",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
      @argparse.PositionArg(
        "requested-effect",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
    ],
  )
  let delegate = @argparse.Command(
    "delegate",
    about="Issue a narrower child permit and reserve its budget",
    options=[
      @argparse.OptionArg("parent-calls", default_values=["2"]),
      @argparse.OptionArg("child-calls", default_values=["1"]),
    ],
    positionals=[
      @argparse.PositionArg(
        "parent-effect",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
      @argparse.PositionArg(
        "child-effect",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
    ],
  )
  let diff = @argparse.Command(
    "diff",
    about="Show whether requested authority needs approval",
    positionals=[
      @argparse.PositionArg(
        "approved-effect",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
      @argparse.PositionArg(
        "requested-effect",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
    ],
  )
  @argparse.Command(
    "moonpermit",
    about="Proof-carrying effect plans for AI agents",
    version="0.1.0",
    default_subcommand="demo",
    subcommands=[
      compile,
      check,
      explain,
      delegate,
      diff,
      @argparse.Command("audit", about="Replay a receipt stream offline"),
      @argparse.Command("demo", about="Run the end-to-end built-in demo"),
    ],
  )
}

///|
fn main raise {
  let matches = cli().parse()
  guard matches.subcommand is Some((name, child)) else {
    raise Failure("a subcommand is required")
  }
  match name {
    "compile" => run_compile(child)
    "check" => run_check(child)
    "explain" => run_explain(child)
    "delegate" => run_delegate(child)
    "diff" => run_diff(child)
    "audit" => run_audit()
    "demo" => run_demo()
    _ => raise Failure("unknown subcommand: " + name)
  }
}
