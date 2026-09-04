# Quality evidence

Baseline recorded on 2026-09-04 using MoonBit `moon 0.1.20260827`, `moonc
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
```

Current result: 55 tests pass. Tests are black-box unless an executable-only
parser requires a white-box package test. The suite includes easy,
intermediate, difficult-boundary, bounded-property, and state-machine cases.

The reviewed MoonBit source snapshot contains 1,725 implementation/example
lines, 1,394 test/benchmark lines, and 492 declarative contract lines (3,611
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

## Coverage

Reproduce with:

```bash
moon coverage analyze -- -f summary
```

| Scope | Covered points | Rate |
| --- | ---: | ---: |
| Core library | 497 / 523 | 95.0% |
| All instrumented source | 558 / 793 | 70.4% |

The all-source denominator includes `cmd/main` and `examples/basic`. Their main
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
| Compile 100 entries into 25 normalized grants | 61.86 µs |
| Create a runtime and authorize 500 calls | 451.48 µs |
| Replay-audit 500 receipts | 281.43 µs |

Each benchmark is deterministic in workload size and validates its retained
result. These measurements are a local regression baseline, not a cross-host
comparison or service-level promise.
