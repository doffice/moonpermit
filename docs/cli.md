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

# Issue a child permit only if it attenuates the live parent authority.
moon run cmd/main -- delegate --parent-calls 2 --child-calls 1 \
  read-tree:docs read:docs/guide.md

# Mark an authority expansion as NEEDS_APPROVAL.
moon run cmd/main -- diff read-tree:docs read:.env

# Run deterministic offline replay over the built-in evidence scenario.
moon run cmd/main -- audit
```

`compile`, `delegate`, and `audit` emit JSON. `check` emits one compact JSON
object per line. `diff` emits a stable review-oriented text form. The library
function `audit_receipts` accepts a permit and receipt array, enabling hosts to
replay persisted logs without contacting an external service.

## Current boundary

The CLI is a dependency-light reference adapter, not a general configuration
loader. It validates all compact DSL inputs through the same constructors as
the library. Filesystem persistence and cryptographic signing remain host
responsibilities and are not claimed by v0.1.
