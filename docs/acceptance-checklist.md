# Hackathon acceptance checklist

The participant-provided nine requirements below are the technical acceptance
gates. Publication to Mooncakes is **mandatory**. Other event-specific skills
are references; they do not replace these requirements or prove eligibility.

## Evidence state (2026-09-30)

The public upstream baseline is main commit `721bdc0`. Its latest CI passed
65 tests on moonc 0.10.12, below the required minimum. The v0.2.0 repair passes
strict checking, formatting, Wasm build, 87 native tests, all CLI workflows,
both examples and native benchmarks on moonc 0.10.14. Its remote branch is
based on actual main history. [PR #10 CI run 36737771009](https://github.com/doffice/moonpermit/actions/runs/36737771009)
passed Ubuntu, macOS, Windows and quality, including 87 default-Wasm tests,
all CLI workflows and both examples. Merge/main CI and publication remain
pending; see `quality.md` for exact source and measured evidence.

| Requirement | Existing evidence | Closure for v0.2.0 |
| --- | --- | --- |
| 1. Mainly MoonBit; moonc >= 0.10.14 | Implementation and tests are MoonBit | CI records successful compiler/core 0.10.14+7d59c7ec9 |
| 2. Public GitHub and clear commits | Public repository and main history | Seven focused repair commits and public PR #10 retain upstream history |
| 3. Clear structure and working core | Scope/planner/runtime/delegation/audit/CLI packages | Composition, tampering and argument-boundary regressions pass natively and on CI |
| 4. Reproducible README | Goal, installation, API, CLI, examples and limits | README and docstring tests plus three-OS workflow verification pass |
| 5. CI checks, builds and tests | Three-OS verify and Linux quality jobs | Updated pinned CI is green; merged main remains a separate gate |
| 6. Runnable example | Basic and guarded-host examples | Both revised examples pass natively and on all three CI platforms |
| 7. Complete core-path tests | Native and default-Wasm suites: 87/87 | CI confirms 565/583 core coverage (96.9%) and 821/939 total (87.4%) |
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
- [x] Commit generated interfaces and repeat default-backend tests on CI.
- [x] Publish a focused PR; pass Ubuntu/macOS/Windows CI and quality job.
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
