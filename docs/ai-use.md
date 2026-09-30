# AI-assisted development record

The 2026 MoonBit September Hackathon permits AI-assisted development while
requiring the participant to understand and own the result. This log makes the
assistance and verification boundary explicit.

## Assistance used

- Ecosystem and prior-art discovery.
- Requirements analysis and issue decomposition.
- Drafting MoonBit APIs, tests, documentation, and CI configuration.
- Interpreting compiler diagnostics and proposing repairs.

## Human responsibility

The repository owner remains responsible for the project goal, submission,
license, technical explanations, security claims, and final demonstration.

## Verification policy

No generated implementation is accepted solely because it looks plausible.
Every public behavior must be backed by executable tests; every milestone ends
with `moon check`, `moon test`, `moon fmt --check`, and `moon info`. External
ideas and specifications are recorded in `prior-art.md`. Unknown-origin code,
private code, credentials, and unlicensed assets are prohibited.

## Initial session — 2026-09-04

- Compared the proposal against public MoonBit Agent, MCP, ACP, replay, and
  observability packages to reduce duplication risk.
- Chose proof-carrying effect plans as the differentiated scope.
- Used the official MoonBit development skills for package, test, formatting,
  and API-review conventions.
- Used `osc2026-guide` only as a conservative engineering checklist; its August
  dates, form links, and referral rules are not treated as September rules.

## Acceptance repair — 2026-09-30

- Reviewed the exact upstream main snapshot `721bdc0` and its CI evidence.
- Drafted complete delegation/check audit events, parameter-safe canonical
  identifiers, regression cases, CLI validation and documentation corrections.
- Followed the MoonBit development guide and used public core interfaces for
  API discovery because `moon ide` was unavailable without a compiler.
- Installed official compiler/core `0.10.14+7d59c7ec9` through authorized browser
  downloads. Used `moon ide` and actual compiler diagnostics to resolve the
  0.10.14 compatibility warnings and new test errors.
- Generated interfaces and formatting with MoonBit tools; passed strict check,
  build, 87 native tests, CLI workflows, examples and native benchmarks.
- Documented the local Wasm runner crash and measured native coverage.
- Submitted seven repair commits through the owner-authorized browser in
  PR #10. CI run 36737771009 passed default-Wasm tests, examples and CLI on
  Ubuntu/macOS/Windows, plus coverage and benchmarks.
- Merged PR #10 at `22878a7`; main CI 36739700598 passed all four jobs. Packaged
  the matching clean source, verified 87 tests in a separately extracted copy,
  and published GitHub v0.2.0 with the archive checksum. Mooncakes publication
  remains blocked on the owner's registry login, not inferred from GitHub login.
