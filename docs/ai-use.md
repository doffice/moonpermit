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
