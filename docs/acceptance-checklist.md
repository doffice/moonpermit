# Acceptance checklist

This checklist combines the current September event page with conservative
engineering gates from the user-provided `osc2026-guide`. September official
notices override any older August-specific detail.

## Registration and process

- [x] Public GitHub repository exists.
- [x] Approximately one-page Markdown proposal exists.
- [ ] Owner submits the official September registration form.
- [ ] Owner joins the event group; this affects reward payment.
- [ ] Proposal receives rolling eligibility approval.
- [ ] Meaningful commits, Issues, pull requests, and update logs remain public.

## Hard repository gates

- [x] Module namespace is `doffice/moonpermit`.
- [x] Root Apache-2.0 license exists.
- [x] MoonBit is the primary implementation language.
- [x] `moon check` and `moon test` pass.
- [x] `moon check --deny-warn` and `moon test --deny-warn` pass.
- [x] `moon fmt --check` passes locally.
- [x] `moon info` is generated and public APIs reviewed locally.
- [ ] CI runs check, test, format, API drift, build, and runnable smoke test.
- [ ] README documents installation, API, CLI, examples, limits, and release.
- [ ] At least one end-to-end example runs without paid services or secrets.
- [ ] Core promises in `proposal.md` are implemented and tested.
- [ ] Repository contains no build cache, secret, temporary, or unknown-origin artifact.
- [ ] Package is published to mooncakes.io and installation is verified.

## Quality and award signals

- [ ] Black-box tests cover all public behavior and difficult boundaries.
- [ ] Property/state-machine tests exercise containment and budget invariants.
- [ ] Coverage report and documented exclusions are reviewed.
- [ ] Benchmarks use deterministic counters plus reproducible timing notes.
- [x] Architecture, threat model, source provenance, and AI use are documented.
- [ ] Effective MoonBit implementation scale is substantial; no filler code.
- [ ] Demo clearly shows allow, deny, exhaustion, expiry, and delegation failure.

## Final manual checks

- [ ] Verify the remote default branch and that all work is visible there.
- [ ] Verify repository owner, primary contributor, and applicant relationship.
- [ ] Re-run the documented commands in a clean clone.
- [ ] Confirm official September submission fields and deadline against current notice.
- [ ] Record a short demonstration and prepare a technical explanation.
