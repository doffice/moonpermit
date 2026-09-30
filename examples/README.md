# Examples

Run the dependency-free basic embedding example from the repository root:

```bash
moon run examples/basic
```

Expected summary:

```text
allowed=true exhausted=true audit=true
```

The parent starts with two calls, delegates one to a child, allows its one
remaining call and then denies exhaustion. `audit_events` replays the
reservation and both decisions, proving the combined workflow is consistent.

Run the guarded Agent Host reference integration:

```bash
moon run examples/guarded_host
```

The example normalizes typed tool calls, calls `Runtime::check_with_proof`, and
invokes a deterministic in-memory executor only after `Allow`. It demonstrates
scope denial, expiry or budget denial, duplicate invocation rejection,
fail-closed unsupported tools, authority-expansion review, and event replay.
It performs no real filesystem, process, network, or secret operation.
