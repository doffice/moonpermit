# Contributing

MoonPermit is being developed in public for the 2026 MoonBit September
Hackathon. Contributions must keep the history, licensing, and verification
evidence reviewable.

Before submitting a change:

```bash
moon check --deny-warn
moon test --deny-warn
moon fmt --check
moon info
```

Use focused commits. Public APIs require black-box tests and documentation.
Never commit credentials, build outputs, private code, or source-unknown
generated content. Declare copied or adapted fixtures and their license in
`docs/prior-art.md` before use.
