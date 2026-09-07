# MoonPermit

[![CI](https://github.com/doffice/moonpermit/actions/workflows/ci.yml/badge.svg)](https://github.com/doffice/moonpermit/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

MoonPermit is a pure MoonBit library and CLI for compiling an AI agent's
structured plan into a least-authority permit, checking every proposed tool
effect against that permit, and emitting an explainable receipt with structured
decision evidence.

The core invariant is:

```text
realized effect <= approved effect
child permit    <= parent permit
```

MoonPermit authorizes effects, not natural-language claims. It is designed to
sit between an agent runtime and its tool executor. It is not an agent
framework, an operating-system sandbox, a prompt-injection detector, or a
production cryptographic credential system.

## Status

MoonPermit is under active development for the 2026 MoonBit September
Hackathon. The repository starts from an empty public project, and development
history is intentionally kept visible.

The [`v0.1.0`](https://github.com/doffice/moonpermit/releases/tag/v0.1.0)
reference release is available from GitHub and
[Mooncakes](https://mooncakes.io/docs/doffice/moonpermit). Scope containment,
budgeted runtime checks, non-amplifying delegation, approval diffs, JSON
receipts, structured authorization proofs, and deterministic offline replay are
implemented and tested.

## Planned workflow

```text
structured plan -> compile minimum permit -> approve once
                -> check each tool call -> allow / deny / request expansion
                -> emit receipt + proof -> audit realized effects
```

## Repository map

- `docs/proposal.md`: one-page hackathon proposal.
- `docs/product-spec.md`: user stories, scope, and acceptance criteria.
- `docs/architecture.md`: effect algebra and trust boundaries.
- `docs/threat-model.md`: security claims and explicit non-claims.
- `docs/acceptance-checklist.md`: continuously maintained release gate.
- `docs/development-log.md`: dated, public development record.
- `docs/quality.md`: reproducible strict gate, coverage, and benchmarks.
- `docs/reviewer-guide.zh.md`: Chinese reviewer guide and three-minute demo.
- `docs/cli.md`: command reference and effect-expression grammar.
- `examples/basic`: dependency-free end-to-end embedding example.
- `cmd/main`: runnable CLI package.

## Quick start

Add the published library to a MoonBit module:

```bash
moon add doffice/moonpermit@0.1.0
```

Install the current stable MoonBit toolchain, clone this repository, and run:

```bash
moon run cmd/main
```

The default demo shows a structured proof, allow, budget exhaustion, expiry,
rejected delegation, an authority expansion diff, and a successful offline
receipt replay. No API key, network service, or paid dependency is needed.

Compile a permit from the compact CLI effect grammar:

```bash
moon run cmd/main -- compile docs-reader --calls 2 \
  read-tree:docs exec:moon,test,--deny-warn
```

Check twice against a one-call grant; stdout is JSONL, one receipt per check:

```bash
moon run cmd/main -- check --calls 1 --repeat 2 \
  read-tree:docs read:docs/guide.md
```

Explain one atomic decision as machine-readable receipt-plus-proof JSON:

```bash
moon run cmd/main -- explain --calls 2 --bytes 10 --expires 20 \
  --cost 4 --now 5 read-tree:docs read:docs/guide.md
```

Other commands are `delegate`, `diff`, and `audit`. See
[`docs/cli.md`](docs/cli.md) for the complete grammar and examples.

## Library sketch

```mbt check
///|
test {
  let permit = @moonpermit.compile_plan("docs", [
    @moonpermit.effect_request(
      @moonpermit.FileRead(@moonpermit.path_tree("docs")),
      @moonpermit.budget(max_calls=1),
    ),
  ])
  let runtime = @moonpermit.runtime(permit)
  let receipt = runtime.check(
    "read-1",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    0L,
  )
  assert_true(receipt.allowed())

  let explained = @moonpermit.runtime(permit).check_with_proof(
    "read-with-proof",
    @moonpermit.FileRead(@moonpermit.path_exact("docs/guide.md")),
    0L,
  )
  assert_true(explained.receipt.allowed())
  assert_eq(explained.proof.reason, @moonpermit.ReasonCode::Granted)
}
```

All runtime time values are explicit logical `Int64` timestamps. Expiry is
exclusive. A finite budget is decremented only after scope, expiry, call, and
byte checks all pass. `check_with_proof` returns its receipt and proof from that
same state transition, so evidence generation never consumes budget twice.

## Development

Install the current stable MoonBit toolchain, then run:

```bash
moon check --deny-warn
moon test --deny-warn
moon fmt --check
moon info
```

See [`docs/quality.md`](docs/quality.md) for the current 62-test result,
coverage denominators, reproducible benchmark workloads, and limitations.

The complete local gate also passes from an isolated clean clone. Release
`v0.1.0` passed the same remote CI matrix and a clean Mooncakes consumer install.

## Security boundary

MoonPermit is an application-level reference monitor. The embedding host must
mediate every protected operation and provide truthful typed effects and time.
Proofs and receipts are deterministic decision evidence, not cryptographic
signatures or reusable authorization credentials. Proof explanations never
copy secret values beyond the typed request identifier already being checked. See
[`docs/threat-model.md`](docs/threat-model.md) and report vulnerabilities as
described in [`SECURITY.md`](SECURITY.md).

## Open source and AI assistance

The project is an original implementation licensed under Apache-2.0. Design
influences, external specifications, and AI-assisted work are recorded in
`docs/prior-art.md` and `docs/ai-use.md`. No third-party implementation is
copied into this repository.

## License

Apache-2.0. See [LICENSE](LICENSE).
