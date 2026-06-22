---
name: clarity-review
description: Review changes against shaped intent first, then tests, types, boundaries, experience, and risk.
---

# Clarity Review

Use this skill before merge, PR, handoff, or whenever a change must be checked against Clarity Engineering intent.

## Goal

Review correctness against shaped intent first.

## Inputs

- Shaped ticket or acceptance details.
- Diff, PR, design, implementation summary, or file paths.
- Relevant tests/check results.

## Review order

1. Shaped intent and acceptance details.
2. Behavior tests and validation evidence.
3. Type/state clarity.
4. Feature boundaries and safe composition.
5. Experience quality / delight.
6. Docs, references, rollout, and risk.

## Output

Decision: `approve`, `request-changes`, `blocked`, or `rescope`.

Then include, as needed:

- prioritized findings;
- evidence or file references;
- suggested fixes;
- risks and follow-up;
- one focused question if human judgement blocks the decision.

## Rules

- Do not start with style nits when intent correctness is unresolved.
- Prefer actionable findings tied to acceptance details.
- Mark rescope when implementation and shaped intent diverge but the new direction may be valid.

