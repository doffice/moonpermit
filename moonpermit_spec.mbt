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
/// Optional limits attached to one effect grant. `None` means unbounded.
pub struct Budget {
  max_calls : Int?
  max_bytes : Int64?
  expires_at : Int64?
} derive(Eq, Debug, ToJson)

///|
/// One requested effect and its intended resource budget.
pub struct EffectRequest {
  effect : EffectScope
  budget : Budget
} derive(Eq, Debug, ToJson)

///|
/// One normalized permit entry.
pub struct Grant {
  id : String
  effect : EffectScope
  budget : Budget
} derive(Eq, Debug, ToJson)

///|
/// A deterministic set of grants approved for one plan.
pub struct Permit {
  id : String
  grants : Array[Grant]
} derive(Eq, Debug, ToJson)

///|
/// One requested grant classified against an already approved permit.
pub(all) struct DiffEntry {
  effect : String
  budget : String
  verdict : Verdict
  covered_by : String?
  explanation : String
} derive(Eq, Debug, ToJson)

///|
/// Deterministic, requested-authority-centric permit comparison.
pub struct PermitDiff {
  approved_id : String
  requested_id : String
  entries : Array[DiffEntry]
} derive(Eq, Debug, ToJson)

///|
/// Invalid permit, budget, or plan input.
pub(all) suberror PermitError {
  EmptyPermitId
  EmptyPlan
  InvalidCallLimit(Int)
  InvalidByteLimit(Int64)
  InvalidExpiry(Int64)
  EmptyInvocationId
  InvalidLogicalTime(Int64)
  InvalidByteCost(Int64)
  ChildAuthorityExceeded(String)
} derive(Eq, Debug, ToJson)

///|
/// Runtime authorization result.
pub(all) enum Verdict {
  Allow
  Deny
  NeedsApproval
} derive(Eq, Debug, ToJson)

///|
/// Stable machine-readable reason for a runtime decision.
pub(all) enum ReasonCode {
  Granted
  NoMatchingGrant
  PermitExpired
  CallBudgetExhausted
  ByteBudgetExhausted
  DuplicateInvocation
} derive(Eq, Debug, ToJson)

///|
/// Explainable evidence emitted for every checked invocation.
pub(all) struct Receipt {
  sequence : Int
  invocation_id : String
  permit_id : String
  verdict : Verdict
  grant_id : String?
  effect : String
  reason : ReasonCode
  message : String
  remaining_calls : Int?
  remaining_bytes : Int64?
} derive(Eq, Debug, ToJson)

///|
/// Stateful, single-owner evaluator for one permit.
pub struct Runtime {
  permit_id : String
  states : Array[GrantState]
  seen_invocations : Set[String]
  receipts : Array[Receipt]
  mut sequence : Int
}

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
/// Return the greatest scope represented by both inputs, or `None` when their
/// effect sets are disjoint.
#declaration_only
pub fn effect_intersection(
  left : EffectScope,
  right : EffectScope,
) -> EffectScope? {
  ...
}

///|
/// Produce a deterministic string used by planners and audit reports.
#declaration_only
pub fn EffectScope::canonical(self : EffectScope) -> String {
  ...
}

///|
/// Construct a validated budget. Omitted fields are unbounded.
#declaration_only
pub fn budget(
  max_calls? : Int,
  max_bytes? : Int64,
  expires_at? : Int64,
) -> Budget raise PermitError {
  ...
}

///|
/// Construct an unbounded budget.
#declaration_only
pub fn unlimited_budget() -> Budget {
  ...
}

///|
/// Return the call limit, or `None` when unbounded.
#declaration_only
pub fn Budget::max_calls(self : Budget) -> Int? {
  ...
}

///|
/// Return the byte limit, or `None` when unbounded.
#declaration_only
pub fn Budget::max_bytes(self : Budget) -> Int64? {
  ...
}

///|
/// Return the exclusive logical expiry, or `None` when unbounded.
#declaration_only
pub fn Budget::expires_at(self : Budget) -> Int64? {
  ...
}

///|
/// Whether every resource allowed by `requested` is covered by `grant`.
#declaration_only
pub fn budget_contains(grant : Budget, requested : Budget) -> Bool {
  ...
}

///|
/// Combine two simultaneous budget constraints by taking each tighter limit.
#declaration_only
pub fn budget_intersection(left : Budget, right : Budget) -> Budget {
  ...
}

///|
/// Build one plan request.
#declaration_only
pub fn effect_request(effect : EffectScope, budget : Budget) -> EffectRequest {
  ...
}

///|
/// Return the requested effect.
#declaration_only
pub fn EffectRequest::effect(self : EffectRequest) -> EffectScope {
  ...
}

///|
/// Return the requested budget.
#declaration_only
pub fn EffectRequest::budget(self : EffectRequest) -> Budget {
  ...
}

///|
/// Compile, sort, and exactly deduplicate a structured plan.
#declaration_only
pub fn compile_plan(
  permit_id : String,
  requests : Array[EffectRequest],
) -> Permit raise PermitError {
  ...
}

///|
/// Return the permit identifier.
#declaration_only
pub fn Permit::id(self : Permit) -> String {
  ...
}

///|
/// Return a defensive copy of the normalized grants.
#declaration_only
pub fn Permit::grants(self : Permit) -> Array[Grant] {
  ...
}

///|
/// Return the number of normalized grants.
#declaration_only
pub fn Permit::grant_count(self : Permit) -> Int {
  ...
}

///|
/// Produce a deterministic, human-readable permit representation.
#declaration_only
pub fn Permit::canonical(self : Permit) -> String {
  ...
}

///|
/// Return the generated grant identifier.
#declaration_only
pub fn Grant::id(self : Grant) -> String {
  ...
}

///|
/// Return the effect scope held by this grant.
#declaration_only
pub fn Grant::effect(self : Grant) -> EffectScope {
  ...
}

///|
/// Return the grant budget.
#declaration_only
pub fn Grant::budget(self : Grant) -> Budget {
  ...
}

///|
/// Whether one grant covers another grant.
#declaration_only
pub fn grant_contains(grant : Grant, requested : Grant) -> Bool {
  ...
}

///|
/// Whether every grant in `requested` is covered by `grant`.
#declaration_only
pub fn permit_contains(grant : Permit, requested : Permit) -> Bool {
  ...
}

///|
/// Compare a requested permit with an existing approval.
#declaration_only
pub fn diff_permits(approved : Permit, requested : Permit) -> PermitDiff {
  ...
}

///|
/// Return diff entries in canonical requested-grant order.
#declaration_only
pub fn PermitDiff::entries(self : PermitDiff) -> Array[DiffEntry] {
  ...
}

///|
/// Whether at least one requested grant expands authority.
#declaration_only
pub fn PermitDiff::requires_approval(self : PermitDiff) -> Bool {
  ...
}

///|
/// Render a stable line-oriented explanation suitable for review.
#declaration_only
pub fn PermitDiff::render(self : PermitDiff) -> String {
  ...
}

///|
/// Start an isolated runtime with fresh counters for one permit.
#declaration_only
pub fn runtime(permit : Permit) -> Runtime {
  ...
}

///|
/// Check and, when allowed, consume one concrete effect invocation.
///
/// `now` is an explicit logical timestamp. Expiry is exclusive.
#declaration_only
pub fn Runtime::check(
  self : Runtime,
  invocation_id : String,
  requested : EffectScope,
  now : Int64,
  byte_cost? : Int64 = 0L,
) -> Receipt raise PermitError {
  ...
}

///|
/// Return the permit identifier attached to this runtime.
#declaration_only
pub fn Runtime::permit_id(self : Runtime) -> String {
  ...
}

///|
/// Return the number of decisions emitted, including denials.
#declaration_only
pub fn Runtime::receipt_count(self : Runtime) -> Int {
  ...
}

///|
/// Return a defensive copy of all receipts in sequence order.
#declaration_only
pub fn Runtime::receipts(self : Runtime) -> Array[Receipt] {
  ...
}

///|
/// Return the current budget for a grant identifier.
#declaration_only
pub fn Runtime::remaining_budget(self : Runtime, grant_id : String) -> Budget? {
  ...
}

///|
/// Issue a child permit by reserving its finite budgets from this runtime.
///
/// The operation is transactional: any unsupported child grant leaves every
/// parent counter unchanged. `now` is used to reject expired parent grants.
#declaration_only
pub fn Runtime::delegate(
  self : Runtime,
  child_id : String,
  requests : Array[EffectRequest],
  now : Int64,
) -> Permit raise PermitError {
  ...
}

///|
/// Convenience predicate for an allow receipt.
#declaration_only
pub fn Receipt::allowed(self : Receipt) -> Bool {
  ...
}
