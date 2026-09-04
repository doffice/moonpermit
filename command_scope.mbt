///|
fn checked_program(program : String) -> String raise ScopeError {
  let normalized = program.trim().to_owned()
  if normalized is "" {
    raise ScopeError::EmptyProgram
  }
  normalized
}

///|
pub fn command_exact(
  program : String,
  arguments : Array[String],
) -> CommandScope raise ScopeError {
  {
    program: checked_program(program),
    arguments: arguments.copy(),
    allow_extra_arguments: false,
  }
}

///|
pub fn command_prefix(
  program : String,
  arguments : Array[String],
) -> CommandScope raise ScopeError {
  {
    program: checked_program(program),
    arguments: arguments.copy(),
    allow_extra_arguments: true,
  }
}

///|
pub fn CommandScope::program(self : CommandScope) -> String {
  self.program
}

///|
pub fn CommandScope::arguments(self : CommandScope) -> Array[String] {
  self.arguments.copy()
}

///|
pub fn CommandScope::allows_extra_arguments(self : CommandScope) -> Bool {
  self.allow_extra_arguments
}

///|
fn arguments_begin_with(
  arguments : Array[String],
  prefix : Array[String],
) -> Bool {
  if arguments.length() < prefix.length() {
    return false
  }
  for index in 0..<prefix.length() {
    if arguments[index] != prefix[index] {
      return false
    }
  }
  true
}

///|
pub fn command_contains(grant : CommandScope, requested : CommandScope) -> Bool {
  if grant.program != requested.program {
    return false
  }
  if !arguments_begin_with(requested.arguments, grant.arguments) {
    return false
  }
  if grant.allow_extra_arguments {
    return true
  }
  !requested.allow_extra_arguments &&
  requested.arguments.length() == grant.arguments.length()
}

///|
fn CommandScope::canonical(self : CommandScope) -> String {
  let fixed = self.arguments.join(" ")
  let base = if fixed is "" { self.program } else { self.program + " " + fixed }
  if self.allow_extra_arguments {
    base + " ..."
  } else {
    base
  }
}
