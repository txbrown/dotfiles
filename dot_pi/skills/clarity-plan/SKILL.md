---
name: clarity-plan
description: Plan shaped work using Plan = Slice + Specify: vertical slices plus acceptance details for the selected next slice.
---

# Clarity Plan

Use this skill when shaped work needs to become an ordered, buildable path.

```text
Plan = Slice + Specify
```

## Inputs

- A shaped ticket or clear request.
- Optional constraints, dependencies, references, risks, and existing acceptance criteria.

## Slice

Create an ordered ticket breakdown around meaningful vertical capability. Prefer slices that each deliver observable value or validated learning.

Include:

- ordered slices;
- purpose/outcome per slice;
- dependencies and sequencing notes;
- AFK/HITL hints where useful;
- risks and assumptions.

Avoid horizontal slices that only move technical layers without meaningful capability unless the ticket type is explicitly Technical Improvement or Chore / Maintenance.

## Specify

For the selected next slice, clarify acceptance details until there is no implementation-blocking ambiguity.

Include:

- examples;
- edge cases;
- expected outcomes;
- non-goals;
- remaining non-blocking questions.

Do not define the first failing test here. Build translates acceptance details into tests.

## Output

- Ordered vertical ticket breakdown.
- Recommended next slice.
- Acceptance details for the recommended or user-selected next slice.
- One focused question if the selected next slice or acceptance behavior is materially ambiguous.

