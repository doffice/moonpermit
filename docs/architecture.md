# Architecture

## Decision pipeline

```text
Plan[EffectRequest]
  -> normalize and merge
  -> Permit[Grant]
  -> RuntimeState(remaining budget, expiry, receipt sequence)
  -> check / check_with_proof(ConcreteEffect)
  -> Decision + Receipt + StructuredProof
```

## Effect lattice

MoonPermit models authority as a partial order. `a <= b` means every action
described by `a` is also authorized by `b`. The comparison is structural:
effect kinds must match, resource scopes must be contained, argument
constraints must be narrower, and requested budgets must not exceed the grant.

The first implementation uses deliberately decidable constraints:

- normalized repository-relative path prefixes;
- exact executable plus argument prefix;
- exact host or subdomain scope and HTTP method set;
- named secret identifiers;
- integer counters and explicit logical time.

Unknown, malformed, or incomparable constraints fail closed.

## Structural intersections

Intersections produce the greatest authority represented by both inputs.
Comparable path, command, and host scopes select the narrower value. Network
scopes additionally intersect HTTP methods and select the less sensitive data
class; an empty method overlap is disjoint. Budget intersections independently
select the tighter finite call, byte, and expiry limits.

## Minimum permit compilation

The planner normalizes and sorts scopes, then merges exact duplicates without
changing their authority meaning. Canonical ordering makes output and tests
deterministic.

The first milestone deliberately deduplicates only identical effect scopes.
Removing a narrower scope beneath a broader scope can accidentally transfer its
budget to unrelated resources, so that optimization is deferred until its
budget algebra is specified and tested. For duplicate scopes, the compiler
takes the least common ceiling of each limit; an unbounded declaration remains
unbounded.

## Approval diff

Permit diffing is intentionally target-centric: each canonically ordered grant
in the requested permit is classified against the existing approval. A grant
contained in one approved grant is marked `COVERED`; otherwise it is marked
`NEEDS_APPROVAL`. Removing or narrowing authority therefore creates no approval
prompt, while any resource or budget expansion does. The rendered form is
stable across equivalent input ordering.

## Delegation

A child request is validated grant by grant against the parent permit. It may
reduce resources, methods, arguments, expiry, and remaining budgets. It may not
introduce a new effect kind or restore consumed authority.

Delegation runs against a runtime snapshot, not the original permit. Finite
child call and byte budgets are reserved from matching parent counters, so
issuing multiple children cannot duplicate a finite allowance. Matching
prefers the tightest usable parent grant. All allocations are staged first and
committed together; a late failure leaves the parent unchanged.

## Runtime enforcement and evidence

Each runtime owns a fresh mutable counter set for one immutable permit. A check
normalizes and reserves its invocation identifier, scans grants in canonical
order, and allows only when scope, expiry, call count, and byte count all pass.
Counters are changed together only after every condition passes. An exhausted
matching grant does not hide a later usable match.

The runtime records allow and deny receipts with a monotonic local sequence,
machine-readable reason, canonical effect, selected grant, and remaining
budget. Reusing an invocation identifier is denied, making accidental retries
visible and preventing double execution through this runtime instance.

`check_with_proof` uses the same state transition as the compatible `check`
method. It returns the emitted receipt together with an `AuthorizationProof`.
The proof lists invocation uniqueness and each considered grant's scope,
expiry, call-budget, and byte-budget outcome. Checks that cannot meaningfully
run after a scope mismatch are explicitly `Skipped`. The decision grant
identifier is copied from the receipt, while allowed budget is consumed once
only after all checks pass.

This proof is structured decision evidence, not a cryptographic object. It is
bound to one runtime sequence and current counter state, and cannot be replayed
as authorization. Generic explanations do not expose secret values beyond a
typed secret identifier already present in the request.

Logical time is supplied explicitly so tests and replays are deterministic.
The embedding host is responsible for a trustworthy clock and durable receipt
storage when those properties are required.

`examples/guarded_host` is the reference adapter boundary. Its single guarded
entry point normalizes a tool call, obtains an atomic receipt and proof, and
invokes an in-memory executor only for `Allow`. Unsupported calls fail closed.
The executor is intentionally fake: the example demonstrates complete host
mediation, not operating-system enforcement or a general Agent framework.

## Offline audit

Receipts retain the normalized typed request, logical time, byte cost, decision,
selected grant, and remaining counters. The auditor starts from a fresh permit
and replays every receipt in order, comparing the complete expected record.
Sequence gaps, wrong permit identifiers, invalid inputs, altered decisions,
and altered accounting are reported as stable finding categories. This detects
inconsistency but is not a cryptographic authenticity claim.

## Trusted computing boundary

The pure decision engine assumes the host mediates every protected tool call
and supplies honest normalized inputs and logical time. Adapters and executors
remain outside the trusted core. See `threat-model.md` for limitations.
