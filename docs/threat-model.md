# Threat model

## Protected properties

Under complete mediation and correct adapter normalization, MoonPermit aims to
ensure:

1. An allowed concrete effect is contained by an active grant.
2. Budget is consumed monotonically and cannot be replayed in one state.
3. A delegated permit is no stronger than its parent at delegation time.
4. Equivalent inputs produce deterministic decisions and receipts.
5. Malformed or unsupported constraints fail closed.

## Threats covered by tests

- Relative-path escape using `..`, duplicate separators, and absolute paths.
- Tool substitution and command-argument widening.
- Network host suffix confusion.
- Expired grants, exhausted counters, and duplicate invocation identifiers.
- Child-agent privilege escalation and budget replenishment.
- Receipt reordering, gaps, and content mismatch.

## Explicit non-claims

MoonPermit is an application-level reference monitor, not an OS sandbox. It
cannot mediate calls that bypass the host integration. It does not prove that a
tool implementation honors its declared effect, detect arbitrary malicious
natural language, protect a compromised host process, or provide production
cryptographic authenticity in v0.1.

Deterministic fingerprints in v0.1 detect accidental inconsistency; they are
not digital signatures and must not be presented as tamper-proof evidence.

## Safe failure policy

Unsupported effects, invalid scopes, missing logical time, ambiguous adapter
input, and internal accounting inconsistencies are denied with structured
reasons. Diagnostics must not echo secret values.
