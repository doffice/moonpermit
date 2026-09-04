# Changelog

All notable changes will be documented here.

## Unreleased

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
