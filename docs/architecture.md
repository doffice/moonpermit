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

## Trusted computing boundary

The pure decision engine assumes the host mediates every protected tool call
and supplies honest normalized inputs and logical time. Adapters and executors
remain outside the trusted core. See `threat-model.md` for limitations.
