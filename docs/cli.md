# CLI reference

Run commands from the repository root with `moon run cmd/main -- <command>`.
Running without a command selects `demo`. Use `--help` at the root or after a
subcommand for generated usage text.

## Effect expressions

| Expression | Meaning |
| --- | --- |
| `read:path` | Exact file read |
| `read-tree:path` | Read a directory and descendants |
| `write:path` | Exact file write |
| `delete:path` | Exact file deletion |
| `exec:program,arg,...` | Exact shell-free command |
| `exec-prefix:program,arg,...` | Fixed command prefix with extra arguments |
| `net:host,METHOD+METHOD,class` | Exact-host network send |
| `net-tree:host,METHOD+METHOD,class` | Apex and subdomain network send |
| `secret:identifier` | Read a named secret |

Data classes are `public`, `internal`, `confidential`, and `secret`. Paths are
repository-relative; absolute paths, parent traversal, and backslashes fail
closed. The compact grammar deliberately has no escaping, so comma-bearing
command arguments require embedding through the typed library API.

## Commands

```bash
# Compile a canonical permit as JSON.
moon run cmd/main -- compile demo --calls 2 read-tree:docs

# Emit JSONL runtime receipts. The second call exhausts the grant.
moon run cmd/main -- check --calls 1 --repeat 2 \
  read-tree:docs read:docs/guide.md

# Explain one atomic decision as deterministic receipt-plus-proof JSON.
moon run cmd/main -- explain --calls 2 --bytes 10 --expires 20 \
  --cost 4 --now 5 read-tree:docs read:docs/guide.md

# Issue a child permit only if it attenuates the live parent authority.
moon run cmd/main -- delegate --parent-calls 2 --child-calls 1 \
  read-tree:docs read:docs/guide.md

# Mark an authority expansion as NEEDS_APPROVAL.
moon run cmd/main -- diff read-tree:docs read:.env

# Replay a successful delegation, allow, exhaustion and scope denial.
moon run cmd/main -- audit
```

`compile`, `explain`, `delegate`, and `audit` emit JSON. `check` emits one
compact JSON object per line. `explain` emits a `receipt` and `proof` from one
runtime transition. The proof records invocation uniqueness plus per-grant
scope, expiry, call-budget, and byte-budget checks as `Pass`, `Fail`, or
`Skipped`; `decision_grant_id` identifies the selected or rejected matching
grant. `diff` emits a stable review-oriented text form. The library function
`audit_events` accepts a permit and an ordered `Runtime::events()` snapshot,
enabling hosts to replay checks and delegated budget reservations without an
external service. `audit_receipts` supports check-only executions.

`check --repeat` must be a positive integer. Negative time, cost and budget
values, invalid integers, missing arguments and unsupported scopes fail with
an error. A valid authorization denial is a successful CLI evaluation whose
receipt contains `Deny`; callers must inspect the verdict before execution.

Command scope identifiers use a JSON array to preserve argument boundaries.
For example, quote `'exec:tool,a b,c'` when passing a space-bearing argument
through the CLI. Commas still require the typed library API.

## Current boundary

The CLI is a dependency-light reference adapter, not a general configuration
loader. It validates all compact DSL inputs through the same constructors as
the library. Filesystem persistence and cryptographic signing remain host
responsibilities and are not claimed by v0.1.
