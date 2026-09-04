# Prior art and originality boundary

MoonPermit is an original MoonBit implementation. No source code from the
projects or specifications below is copied into this repository.

## Public design references

- Model Context Protocol security model:
  https://github.com/modelcontextprotocol/modelcontextprotocol/security
- MCP 2026-07-28 release and application-level authorization boundary:
  https://blog.modelcontextprotocol.io/posts/2026-07-28/
- IETF Internet-Draft, Attenuating Authorization Tokens for Agentic Delegation:
  https://www.ietf.org/archive/id/draft-niyikiza-oauth-attenuating-agent-tokens-01.html
- Object-capability and least-authority concepts, used as general design ideas.

## MoonBit ecosystem comparison

- `colmugx/posoco` provides an Agent runtime and pre-tool hooks.
- `colmugx/acp` provides typed protocol transport for permission requests.
- `bobzhang/workflow` provides journaled workflow replay.
- `moonbit-community/opentelemetry` provides general observability.
- `moonbit-community/quickcheck_statemachine` provides state-machine testing.

MoonPermit does not replace those projects. Its independent contribution is a
small, framework-neutral effect algebra plus minimum-permit compilation,
authority-expansion diffs, consumable budgets, monotonic delegation, and
execution receipts.

## Source and fixture policy

- All implementation code is written for this repository.
- Tests use synthetic data authored for MoonPermit.
- Any future borrowed fixture or generated artifact must be listed here with
  its source, license, and transformation before it is committed.
