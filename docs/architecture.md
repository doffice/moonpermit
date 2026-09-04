# Architecture

## Decision pipeline

```text
Plan[EffectRequest]
  -> normalize and merge
  -> Permit[Grant]
  -> RuntimeState(remaining budget, expiry, receipt sequence)
  -> check(ConcreteEffect)
  -> Decision + Receipt
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

## Delegation

A child request is validated grant by grant against the parent permit. It may
reduce resources, methods, arguments, expiry, and remaining budgets. It may not
introduce a new effect kind or restore consumed authority.

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

Logical time is supplied explicitly so tests and replays are deterministic.
The embedding host is responsible for a trustworthy clock and durable receipt
storage when those properties are required.

## Trusted computing boundary

The pure decision engine assumes the host mediates every protected tool call
and supplies honest normalized inputs and logical time. Adapters and executors
remain outside the trusted core. See `threat-model.md` for limitations.
