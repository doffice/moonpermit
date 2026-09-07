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

## 2026-09-04 — Non-amplifying delegation milestone

- Added child-permit issuance from live remaining parent authority.
- Reserved finite call and byte budgets instead of copying them.
- Made multi-grant allocation transactional and fail closed on late failure.
- Preferred tighter matching grants to preserve broader authority.
- Covered scope escalation, consumed-budget replenishment, rollback, overlap,
  and expiry with six black-box tests.
- Verified 29 tests under `--deny-warn`.

Next gate: add structural intersections and authority-expansion diffs.

## 2026-09-04 — Intersection and approval-diff milestone

- Added greatest-common effect intersections for paths, commands, networks,
  secrets, and separate tightest-limit budget intersections.
- Added deterministic requested-authority diffs with `COVERED` and
  `NEEDS_APPROVAL` classifications.
- Ensured narrowing and reordering do not trigger approval while resource and
  budget expansion do.
- Added eight black-box tests for comparable, disjoint, mixed-network, and
  deterministic-diff cases.
- Verified 37 tests under `--deny-warn`.

Next gate: deliver a runnable CLI vertical slice and offline receipt audit.

## 2026-09-04 — Runnable vertical slice and replay audit

- Made receipts replay-complete with typed requests, logical time, and cost.
- Added deterministic offline audit with sequence, permit, input, decision, and
  accounting tamper detection.
- Replaced the placeholder executable with `compile`, `check`, `delegate`,
  `diff`, `audit`, and comprehensive default `demo` commands.
- Added compact validated effect expressions and JSON/JSONL output.
- Added a standalone no-service embedding example and CI execution step.
- Verified every CLI command plus 43 tests under `--deny-warn`.

Next gate: add property/state-machine testing, coverage, and benchmarks.

## 2026-09-04 — Quality and toolchain-compatibility milestone

- Added bounded algebra properties and runtime/delegation state machines.
- Migrated the formal contract from legacy `#declaration_only` blocks to the
  current bodyless `declare` syntax after coverage exposed the incompatibility.
- Raised the suite to 55 passing tests under `--deny-warn`.
- Measured 497/523 core coverage points (95.0%) and transparently recorded the
  lower 558/793 all-source result (70.4%) caused by executable adapters.
- Added deterministic release benchmarks for compile, check, and audit paths.
- Added an Ubuntu CI quality job for coverage and release benchmarks.
- Added a focused overlapping-grant regression and changed runtime selection to
  preserve broader authority by consuming the tightest usable grant first.

Next gate: final repository audit, clean-clone verification, and remote CI.

## 2026-09-04 — Local acceptance milestone

- Passed the complete strict gate with 55/55 tests, a clean API generation
  diff, the built-in audit workflow, and the standalone embedding example.
- Repeated the gate from an isolated local clone to prove the build does not
  depend on ignored or untracked workspace files.
- Reviewed all tracked paths, confirmed `_build/` remains ignored, and scanned
  the source tree for common private-key and access-token signatures.
- Recorded a transparent 3,611-line MoonBit source breakdown: 1,725
  implementation/example, 1,394 test/benchmark, and 492 contract lines.

Next gate: publish `main`, observe remote CI, and await rolling eligibility
review.

## 2026-09-04 — Public CI milestone

- Published the full 11-commit history to the public `doffice/moonpermit`
  repository with `main` as the remote default branch.
- Verified the remote branch points to the same `181290e` commit as the local
  accepted clone.
- GitHub Actions run #1 passed all four jobs: Ubuntu, macOS, Windows, and the
  coverage/benchmark quality job.

Next gate: create public planning/review artifacts, evaluate optional Mooncakes
distribution, and complete repository-side eligibility evidence.

## 2026-09-07 — Structured authorization proof milestone

- Added public proof check kinds, pass/fail/skipped states, proof entries,
  authorization proofs, and atomic checked-result types.
- Refactored legacy `Runtime::check` onto `check_with_proof` while preserving its
  public signature, receipt shape, grant choice, and single budget consumption.
- Added deterministic `explain` JSON output and included proof evidence in the
  built-in demo.
- Added seven black-box tests for allow, scope mismatch, expiry, call and byte
  exhaustion, duplicate invocation, overlapping grants, atomicity, and stable
  serialization; verified 62 tests under `--deny-warn`.

Next gate: regenerate the public interface, measure coverage, pass the complete
strict gate, and publish the feature branch for review through Issue #1.

## 2026-09-07 — v0.1.0 release milestone

- Merged PR #2 and closed Issue #1 with all Ubuntu, macOS, Windows, coverage,
  benchmark, API-drift, CLI, and embedding checks passing.
- Published the annotated `v0.1.0` Git tag and GitHub Release from merge commit
  `619328f`.
- Published `doffice/moonpermit@0.1.0` to Mooncakes; the registry build and
  generated API documentation succeeded.
- Verified the registry checksum against the locally audited package and added
  the dependency to a fresh module that passed `moon check --deny-warn`.

Next gate: package the stable release links, demo flow, and verification evidence
for submission review.
