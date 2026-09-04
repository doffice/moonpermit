///|
/// Sensitivity carried by data sent through a network effect.
pub(all) enum DataClass {
  Public
  Internal
  Confidential
  Secret
} derive(Eq, Debug, ToJson)

///|
/// A normalized repository-relative path scope.
///
/// Values can only be created through `path_exact` and `path_tree`, so an
/// accepted value never contains an absolute path or a parent traversal.
pub struct PathScope {
  canonical : String
  tree : Bool
} derive(Eq, Debug, ToJson)

///|
/// A shell-free executable and argument scope.
pub struct CommandScope {
  program : String
  arguments : Array[String]
  allow_extra_arguments : Bool
} derive(Eq, Debug, ToJson)

///|
/// A normalized DNS host scope.
pub struct HostScope {
  canonical : String
  subdomains : Bool
} derive(Eq, Debug, ToJson)

///|
/// Network authority combines a host scope, normalized HTTP methods, and the
/// most sensitive data class that may leave the host.
pub struct NetworkScope {
  host : HostScope
  methods : Array[String]
  max_data_class : DataClass
} derive(Eq, Debug, ToJson)

///|
/// Authority over an externally visible effect.
pub(all) enum EffectScope {
  FileRead(PathScope)
  FileWrite(PathScope)
  FileDelete(PathScope)
  ProcessExec(CommandScope)
  NetworkSend(NetworkScope)
  SecretRead(String)
} derive(Eq, Debug, ToJson)

///|
/// Why construction of a scope failed.
pub(all) suberror ScopeError {
  EmptyPath
  AbsolutePath(String)
  ParentTraversal(String)
  AmbiguousSeparator(String)
  EmptyProgram
  InvalidHost(String)
  EmptyMethodSet
  InvalidMethod(String)
  EmptySecret
} derive(Eq, Debug, ToJson)

///|
/// Structured result of an authority containment check.
pub(all) enum Containment {
  Contained
  NotContained(reason~ : String)
} derive(Eq, Debug, ToJson)

///|
/// Build an exact repository-relative path scope.
#declaration_only
pub fn path_exact(input : String) -> PathScope raise ScopeError {
  ...
}

///|
/// Build a tree scope containing a directory and all of its descendants.
///
/// `path_tree(".")` represents the entire repository tree.
#declaration_only
pub fn path_tree(input : String) -> PathScope raise ScopeError {
  ...
}

///|
/// Return the stable external form, such as `docs/guide.md` or `docs/**`.
#declaration_only
pub fn PathScope::canonical(self : PathScope) -> String {
  ...
}

///|
/// Whether this path represents a tree rather than one exact resource.
#declaration_only
pub fn PathScope::is_tree(self : PathScope) -> Bool {
  ...
}

///|
/// Test whether every resource in `requested` is covered by `grant`.
#declaration_only
pub fn path_contains(grant : PathScope, requested : PathScope) -> Bool {
  ...
}

///|
/// Authorize exactly one shell-free executable invocation.
#declaration_only
pub fn command_exact(
  program : String,
  arguments : Array[String],
) -> CommandScope raise ScopeError {
  ...
}

///|
/// Authorize invocations beginning with a fixed executable and argument prefix.
#declaration_only
pub fn command_prefix(
  program : String,
  arguments : Array[String],
) -> CommandScope raise ScopeError {
  ...
}

///|
/// Return the exact executable name.
#declaration_only
pub fn CommandScope::program(self : CommandScope) -> String {
  ...
}

///|
/// Return a defensive copy of the fixed argument portion.
#declaration_only
pub fn CommandScope::arguments(self : CommandScope) -> Array[String] {
  ...
}

///|
/// Whether additional arguments are allowed after the fixed prefix.
#declaration_only
pub fn CommandScope::allows_extra_arguments(self : CommandScope) -> Bool {
  ...
}

///|
/// Test whether every invocation in `requested` is covered by `grant`.
#declaration_only
pub fn command_contains(grant : CommandScope, requested : CommandScope) -> Bool {
  ...
}

///|
/// Build an exact DNS host scope.
#declaration_only
pub fn host_exact(input : String) -> HostScope raise ScopeError {
  ...
}

///|
/// Build a host scope containing the apex and its subdomains.
#declaration_only
pub fn host_and_subdomains(input : String) -> HostScope raise ScopeError {
  ...
}

///|
/// Return the normalized lowercase host form.
#declaration_only
pub fn HostScope::canonical(self : HostScope) -> String {
  ...
}

///|
/// Whether the apex scope includes subdomains.
#declaration_only
pub fn HostScope::includes_subdomains(self : HostScope) -> Bool {
  ...
}

///|
/// Test whether every host in `requested` is covered by `grant`.
#declaration_only
pub fn host_contains(grant : HostScope, requested : HostScope) -> Bool {
  ...
}

///|
/// Build a normalized network scope.
#declaration_only
pub fn network_scope(
  host : HostScope,
  methods : Array[String],
  max_data_class : DataClass,
) -> NetworkScope raise ScopeError {
  ...
}

///|
/// Test whether every network action in `requested` is covered by `grant`.
#declaration_only
pub fn network_contains(grant : NetworkScope, requested : NetworkScope) -> Bool {
  ...
}

///|
/// Compare arbitrary effect scopes using fail-closed structural rules.
#declaration_only
pub fn effect_contains(
  grant : EffectScope,
  requested : EffectScope,
) -> Containment {
  ...
}

///|
/// Produce a deterministic string used by planners and audit reports.
#declaration_only
pub fn EffectScope::canonical(self : EffectScope) -> String {
  ...
}
