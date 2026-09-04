# Development log

## 2026-09-04 — Project initialization

- Created the public `doffice/moonpermit` repository from an empty project.
- Audited the current September event source and separated it from the older
  August-specific acceptance guide.
- Installed MoonBit `moonc 0.10.11` and generated a current `moon.mod` project.
- Fixed the product boundary, non-goals, threat model, prior-art disclosure,
  proposal, and continuously maintained acceptance checklist.

Next gate: implement and test the formal effect/scope contract.

## 2026-09-04 — Effect scope milestone

- Added a contract-first public API in `moonpermit_spec.mbt`.
- Implemented normalized repository paths with absolute-path, parent-traversal,
  and ambiguous-separator rejection.
- Implemented shell-free command prefix attenuation and DNS-label-safe host
  containment.
- Implemented HTTP method/data-class constraints and structural effect checks.
- Added ten black-box tests across easy, intermediate, and difficult cases.
- Verified `moon check --deny-warn` and `moon test --deny-warn`.

Next gate: add permit compilation, budgets, runtime consumption, and delegation.

## 2026-09-04 — Permit compiler milestone

- Added validated optional call, byte, and logical-expiry budgets.
- Defined budget containment with explicit unbounded semantics.
- Added deterministic plan sorting, exact-effect deduplication, and generated
  grant identifiers.
- Kept scope minimization conservative where merging could redistribute budget.
- Added permit/grant containment and six new black-box tests.
- Verified 16 tests under `--deny-warn`.

Next gate: consume budgets at runtime and emit deterministic receipts.

## 2026-09-04 — Runtime enforcement milestone

- Added stateful checks for scope, expiry, call budgets, and byte budgets.
- Made successful budget consumption atomic: failed checks consume nothing.
- Added invocation replay protection and a receipt for every allow or denial.
- Kept grant selection deterministic while permitting fallback to another
  matching grant that still has budget.
- Added seven black-box runtime tests, including malformed metadata boundaries.
- Verified 23 tests under `--deny-warn` and reviewed generated public APIs.

Next gate: implement provably attenuating child-permit delegation.
