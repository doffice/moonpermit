# Changelog

All notable changes will be documented here.

## Unreleased

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
