# MoonPermit

[![CI](https://github.com/doffice/moonpermit/actions/workflows/ci.yml/badge.svg)](https://github.com/doffice/moonpermit/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

MoonPermit is a pure MoonBit library and CLI for compiling an AI agent's
structured plan into a least-authority permit, checking every proposed tool
effect against that permit, and emitting an explainable execution receipt.

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

Current milestone: formal effect model and executable specification tests.

## Planned workflow

```text
structured plan -> compile minimum permit -> approve once
                -> check each tool call -> allow / deny / request expansion
                -> emit deterministic receipts -> audit realized effects
```

## Repository map

- `docs/proposal.md`: one-page hackathon proposal.
- `docs/product-spec.md`: user stories, scope, and acceptance criteria.
- `docs/architecture.md`: effect algebra and trust boundaries.
- `docs/threat-model.md`: security claims and explicit non-claims.
- `docs/acceptance-checklist.md`: continuously maintained release gate.
- `docs/development-log.md`: dated, public development record.
- `cmd/main`: runnable CLI package.

## Development

Install the current stable MoonBit toolchain, then run:

```bash
moon check --deny-warn
moon test --deny-warn
moon fmt --check
moon info
```

The CLI and runnable examples will be documented as soon as the first vertical
slice lands. Until then, the repository should be treated as a transparent
work in progress rather than a completed security product.

## Open source and AI assistance

The project is an original implementation licensed under Apache-2.0. Design
influences, external specifications, and AI-assisted work are recorded in
`docs/prior-art.md` and `docs/ai-use.md`. No third-party implementation is
copied into this repository.

## License

Apache-2.0. See [LICENSE](LICENSE).
