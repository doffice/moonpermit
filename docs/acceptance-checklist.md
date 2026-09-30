# Hackathon acceptance checklist

The participant-provided nine requirements below are the technical acceptance
gates. Publication to Mooncakes is **mandatory**. Other event-specific skills
are references; they do not replace these requirements or prove eligibility.

## Evidence state (2026-09-30)

The public upstream baseline is main commit `721bdc0`. Its latest CI passed
65 tests on moonc 0.10.12, below the required minimum. The v0.2.0 repair passes
strict checking, formatting, Wasm build, 87 native tests, all CLI workflows,
both examples and native benchmarks on moonc 0.10.14. Its remote branch is
based on actual main history. Default-backend CI, merging and publishing are
pending; see `quality.md` for the local Wasm runner limitation.

| Requirement | Existing evidence | Closure for v0.2.0 |
| --- | --- | --- |
| 1. Mainly MoonBit; moonc >= 0.10.14 | Implementation and tests are MoonBit; local compiler is 0.10.14 | CI pins matching compiler/core; actual successful remote run pending |
| 2. Public GitHub and clear commits | Public repository and main history | Submit repair commits and PR through the owner-authorized browser |
| 3. Clear structure and working core | Scope/planner/runtime/delegation/audit/CLI packages | New composition, tampering and argument-boundary regressions pass natively |
| 4. Reproducible README | Goal, installation, API, CLI, examples and limits | Tested README examples, migration and toolchain guidance; clean remote verification pending |
| 5. CI checks, builds and tests | Three-OS verify and Linux quality jobs | Updated pinned CI and every CLI subcommand must run; merged main must be green |
| 6. Runnable example | Basic and guarded-host examples | Both revised examples pass natively; repeat on three-platform CI |
| 7. Complete core-path tests | Current native suite: 87/87; core 565/583 (96.9%) | Default-backend remote tests and coverage must also pass |
| 8. Publish to mooncakes.io | `doffice/moonpermit@0.1.1` exists | Publish the verified v0.2.0 source and validate a clean consumer install |
| 9. OSI-approved license and provenance | Apache-2.0 LICENSE; prior-art and AI-use records | Retain license, original-source policy and reviewed dependency provenance |

## Required execution gates

- [x] Prepare code and regression sources for delegation/check composition.
- [x] Prepare unambiguous command identifiers and input-order regression sources.
- [x] Prepare CLI behavior/error cases and both examples.
- [x] Pin compiler/core >= 0.10.14 and retain check/build/test CI gates.
- [x] Update README, migration guidance, changelog and mandatory distribution status.
- [x] Install and record the actual compliant compiler and matching core.
- [x] Run `moon fmt` and `moon info`; review generated interfaces.
- [x] Pass `moon check --deny-warn` and 87/87 native tests under `--deny-warn`.
- [x] Pass `moon fmt --check`, Wasm build, all native CLI commands and examples.
- [x] Measure native coverage and pass 3/3 native release benchmarks.
- [ ] Commit generated interfaces and repeat default-backend tests on CI.
- [ ] Publish a focused PR; pass Ubuntu/macOS/Windows CI and quality job.
- [ ] Merge the green repair and verify CI on the resulting main commit.
- [ ] Publish matching GitHub v0.2.0 and Mooncakes 0.2.0 artifacts.
- [ ] Install 0.2.0 in a fresh consumer module and run its delegation/audit sample.
- [ ] Replace pending statements with actual commit/run/release links and results.

## Event administration

Eligibility approval, the official deadline and any demonstration requirement
must be checked against the participant's event notice. They cannot be inferred
from this repository. The supplied acceptance text says approved participants
do not need to submit another form before acceptance; do not introduce a new
form requirement from older guides.
