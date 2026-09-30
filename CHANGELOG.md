# Changelog

All notable changes will be documented here.

## Unreleased

## 0.2.0 - 2026-09-30

GitHub source/package release verified; Mooncakes publication and a fresh
registry consumer remain pending authenticated upload.

- Record successful child-budget reservations alongside authorization checks
  through `Runtime::events` and replay the complete stream with `audit_events`.
- Preserve `Receipt` and check-only `audit_receipts`; document separate event
  sequencing, rollback behavior and evidence migration.
- Fix process canonical identifiers using JSON argument arrays. This changes
  command strings and potentially grant order; replay old logs with v0.1.
- Add regressions for delegation/check composition, altered evidence, snapshot
  isolation, parameter boundaries, deterministic plans and all CLI subcommands.
- Reject non-positive CLI repeat counts and align the CLI version with the module.
- Pin CI's compiler and core to `0.10.14+7d59c7ec9` and run every CLI workflow
  plus both examples on Ubuntu, macOS and Windows.
- Explicitly extend public derived methods for MoonBit 0.10.14 compatibility;
  regenerate the public interface with `moon info`.
- Correct the acceptance checklist and distinguish historical quality results
  from this source's passing three-platform CI, 87 tests and 96.9% core coverage.
- Merge PR #10 with its nine focused commits; pass main CI 36739700598 and
  publish GitHub v0.2.0 with a checksummed package from source commit `22878a7`.

## 0.1.1 - 2026-09-11

- Added a deterministic, dependency-free guarded Agent Host example with a
  single authorization boundary and in-memory fake executor.
- Added integration tests proving one executor call after `Allow` and zero
  calls after scope, expiry, budget, duplicate, or unsupported-tool denial.
- Added the guarded-host smoke test to the cross-platform CI matrix and
  documented its security boundary and review flow.

## 0.1.0 - 2026-09-07

- Initialized the MoonPermit proposal, governance, threat model, and acceptance gates.
- Added normalized path, command, host, network, and effect scopes.
- Added structural authority-containment checks with fail-closed mismatch reasons.
- Added easy, intermediate, and difficult black-box specification tests.
- Added budget validation, plan compilation, exact-scope deduplication, and
  permit containment.
- Added runtime scope enforcement, atomic budget consumption, expiry checks,
  replay protection, grant fallback, and deterministic decision receipts.
- Added transactional child-permit delegation that reserves finite parent
  budgets and rejects scope widening, replenishment, and expired authority.
- Added structural effect and budget intersections plus deterministic permit
  diffs that isolate authority requiring new approval.
- Added replay-complete receipts, offline audit, a validated effect DSL, five
  CLI workflows, a comprehensive demo, and a standalone embedding example.
- Added bounded property/state-machine tests, 95.0% measured core coverage,
  reproducible release benchmarks, and current `declare` contract syntax.
- Runtime authorization now consumes the tightest usable overlapping grant so
  broader authority remains available for effects that require it.
- Added structured per-check authorization proofs and an atomic
  `Runtime::check_with_proof` API without changing legacy receipt behavior.
- Added a deterministic `explain` CLI command plus black-box coverage for allow,
  scope mismatch, expiry, exhausted budgets, duplicate calls, and grant overlap.
