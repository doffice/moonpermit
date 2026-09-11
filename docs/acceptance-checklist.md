# Acceptance checklist

This checklist combines the current September event page with conservative
engineering gates from the user-provided `osc2026-guide`. September official
notices override any older August-specific detail.

## Public project process

- [x] Public GitHub repository exists.
- [x] Approximately one-page Markdown proposal exists.
- [ ] Proposal receives rolling eligibility approval.
- [x] Meaningful commits, Issues, pull requests, and update logs remain public.

## Hard repository gates

- [x] Module namespace is `doffice/moonpermit`.
- [x] Root Apache-2.0 license exists.
- [x] MoonBit is the primary implementation language.
- [x] `moon check` and `moon test` pass.
- [x] `moon check --deny-warn` and `moon test --deny-warn` pass.
- [x] `moon fmt --check` passes locally.
- [x] `moon info` is generated and public APIs reviewed locally.
- [x] CI runs check, test, format, API drift, build, and runnable smoke test.
- [x] README documents installation, API, CLI, examples, limits, and release status.
- [x] At least one end-to-end example runs without paid services or secrets.
- [x] Guarded-host example proves allow-once and deny-without-side-effect flow.
- [x] Core promises in `proposal.md` are implemented and tested.
- [x] `check_with_proof` emits receipt and structured proof atomically.
- [x] Proof tests cover allow, scope, expiry, call, byte, replay, and overlap.
- [x] `explain` emits deterministic machine-readable JSON.
- [x] Git tracks no build cache, secret, temporary, or unknown-origin artifact.

## Quality and award signals

- [x] Black-box tests cover core public behavior and difficult boundaries.
- [x] Property/state-machine tests exercise containment and budget invariants.
- [x] Coverage report and documented adapter gap are reviewed.
- [x] Benchmarks use deterministic workloads plus reproducible timing notes.
- [x] Architecture, threat model, source provenance, and AI use are documented.
- [x] Effective MoonBit implementation scale is substantial; no filler code.
- [x] Demo clearly shows allow, deny, exhaustion, expiry, and delegation failure.

## Optional distribution

- [x] Published `doffice/moonpermit@0.1.0` to Mooncakes and verified a clean install.
- [x] Published GitHub Release `v0.1.0` from the accepted `main` commit.
- [x] Published and verified the `v0.1.1` GitHub and Mooncakes patch release.

## Final manual checks

- [x] Verify the remote default branch and that all work is visible there.
- [x] Verify repository owner, primary contributor, and applicant relationship.
- [x] Re-run the documented commands in a clean clone.
- [ ] Confirm official September submission fields and deadline against current notice.
- [ ] Record a short demonstration and prepare a technical explanation.
