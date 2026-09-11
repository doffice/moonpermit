# Quality evidence

Baseline updated on 2026-09-11 using MoonBit `moon 0.1.20260827`, `moonc
v0.10.11+6ff76a5f9`, Linux x86_64. Exact timings vary by host; the commands and
workloads, rather than these numbers, are the regression contract.

## Strict gate

```bash
moon check --deny-warn
moon test --deny-warn
moon fmt --check
moon info
moon build
moon run cmd/main
moon run examples/basic
moon run examples/guarded_host
```

Current result: 65 tests pass. Tests are black-box unless an executable-only
parser requires a white-box package test. The suite includes easy,
intermediate, difficult-boundary, bounded-property, and state-machine cases.

Remote CI run [34579333431](https://github.com/doffice/moonpermit/actions/runs/34579333431)
passed on Ubuntu, macOS, and Windows, with a separate Ubuntu quality job for
coverage and release benchmarks. The run tested release commit `5545c44` on
2026-09-11.

The `doffice/moonpermit@0.1.0` Mooncakes artifact has SHA-256
`78b46c2a9b0e03f42d97d79351624632011226fa6583fbba1c92c0f99171d2fd`.
Mooncakes reported a successful registry build, and a fresh temporary module
resolved the published dependency and passed `moon check --deny-warn`.

The `doffice/moonpermit@0.1.1` Mooncakes artifact has SHA-256
`08875e7b5b59f035475d7673adc2b8a05df8efa068026076574e3ce63f05087e`.
The registry returned `200 OK`; its public version page returned HTTP 200, and
a fresh temporary module downloaded `0.1.1` and passed `moon check --deny-warn`.

The reviewed MoonBit source snapshot contains 1,939 implementation/example
lines, 1,611 test/benchmark lines, and 556 declarative contract lines (4,106
total). Generated interfaces and build output are excluded. These categories
are reported separately so test or declaration volume cannot masquerade as
implementation scale; no filler was added to reach a line-count target.

The bounded properties cover containment reflexivity and transitivity,
intersection commutativity/lower bounds, exact finite-call consumption,
denial non-consumption, replay behavior, audit replay, and conservation of
finite delegated calls.

The runtime regression cases also verify that an exact grant is consumed
before an overlapping tree grant, preserving broader authority for requests
that genuinely need it.

Authorization-proof tests cover allow, scope mismatch, expiry, exhausted call
and byte budgets, duplicate invocation, overlapping grants, legacy API
compatibility, single consumption, and deterministic JSON serialization.

Guarded-host integration tests additionally prove that `Allow` reaches its
in-memory executor exactly once, while scope, expiry, budget, duplicate, and
unsupported-tool denials reach it zero times. The example also verifies an
authority expansion diff and deterministic offline receipt audit.

## Coverage

Reproduce with:

```bash
moon coverage analyze -- -f summary
```

| Scope | Covered points | Rate |
| --- | ---: | ---: |
| Core library | 528 / 550 | 96.0% |
| All instrumented source | 639 / 890 | 71.8% |

The all-source denominator includes `cmd/main`, `examples/basic`, and
`examples/guarded_host`. Their main
functions are executed by the strict gate and CI, but executable runs do not
feed MoonBit's unit-test coverage trace. Both figures are reported to avoid
hiding this distinction. Generated interfaces and staged declarations are not
counted as executable coverage points.

Coverage initially exposed an incompatibility between the older
`#declaration_only { ... }` skill template and the current coverage compiler.
The contract was migrated to the current bodyless `declare` syntax instead of
excluding it or abandoning coverage.

## Benchmarks

Reproduce on one otherwise-idle host with:

```bash
moon bench --release --deny-warn
```

| Release-mode workload | Baseline mean |
| --- | ---: |
| Compile 100 entries into 25 normalized grants | 62.45 µs |
| Create a runtime and authorize 500 calls | 538.45 µs |
| Replay-audit 500 receipts | 354.52 µs |

Each benchmark is deterministic in workload size and validates its retained
result. These measurements are a local regression baseline, not a cross-host
comparison or service-level promise.
