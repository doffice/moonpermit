# Product specification

## Problem

An agent host needs to decide whether a concrete tool call is covered by the
user's approval. A tool name alone is too coarse: `write_file` may target one
document or a credential file, and `run` may execute a fixed test command or an
arbitrary shell program.

## Product promise

Given a structured plan, MoonPermit produces a normalized, minimum permit.
Given that permit and a concrete effect, it returns a deterministic decision
with an explanation and an auditable receipt. Delegated permits must be no more
powerful than their parent.

## Primary users

- Authors of coding-agent runtimes and tool gateways.
- MCP/ACP host implementers that need application-level authorization.
- CI maintainers who want offline regression tests for agent authority.

## Required v0.1 capabilities

1. Typed file, process, network, secret, and budget effects.
2. Canonical normalization independent of input order.
3. Scope containment and intersection with explicit mismatch reasons.
4. Minimum-permit compilation from a structured effect plan.
5. Stateful call/byte budget consumption and expiry checks.
6. Monotonic delegation: a child cannot widen scope or replenish budget.
7. Plan diff that requests approval only for authority expansion.
8. JSON/JSONL receipts and offline audit verification.
9. A dependency-light CLI and at least one end-to-end demo.

## Acceptance scenarios

- A permit for `docs/**` accepts `docs/README.md` and rejects `.env`.
- A permit for exact `moon test` rejects `sh -c curl ...`.
- A one-use execution grant rejects the second invocation.
- An expired permit rejects every protected effect.
- A child permit with network access is rejected when its parent has none.
- Reordered equivalent plans compile to identical canonical output.
- Every denial identifies the failed constraint without leaking secret data.

## Non-goals for v0.1

- Understanding whether free-form natural language is honest.
- Executing tools or providing an operating-system sandbox.
- Detecting every prompt-injection payload.
- Issuing production cryptographic identity or authorization tokens.
- Replacing MCP, ACP, an agent framework, IAM, or OpenTelemetry.
