---
name: clarity-build
description: Build a selected Clarity Engineering slice TDD-first from acceptance details.
---

# Clarity Build

Use this skill when a slice is ready to implement.

## Goal

Implement behavior, prove it with tests, improve design safely, and keep feedback tight.

Default discipline:

```text
Red → Green → Refactor
```

## Inputs

- Selected slice.
- Acceptance details from Plan.
- Relevant code paths, constraints, and validation commands.

## Output

- First failing behavior test or explanation if a test-first path is technically impossible.
- Smallest useful implementation.
- Checks run and results.
- Refactor notes while green.
- Files changed and any follow-up needed.

## Rules

- Translate acceptance details into the first failing behavior test.
- Test public behavior, not private implementation.
- Implement the smallest useful behavior.
- Run checks continuously.
- Preserve feature boundaries.
- Update docs/references where needed.
- If acceptance behavior is ambiguous, ask one focused question before coding.

