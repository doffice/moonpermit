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
