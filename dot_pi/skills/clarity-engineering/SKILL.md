---
name: clarity-engineering
description: Apply Ricardo's Clarity Engineering framework consistently with AI. Use for routing work across Shape, Plan, Build, Review, and Compound.
---

# Clarity Engineering Router

Use this skill when a request should be handled through Clarity Engineering or when the user asks for Clarity Engineering generally.

Lifecycle:

```text
Shape → Plan → Build → Review → Compound
```

Plan contains two substeps:

```text
Plan = Slice + Specify
```

## Inputs

- A raw idea, request, ticket, plan, diff, implementation task, or completed-work recap.
- Optional context such as constraints, references, code paths, or acceptance criteria.

## Routing

Route to the most useful mode:

- Shape: fuzzy idea, unclear problem, or deliverable work without a ticket.
- Plan: shaped work that needs vertical slicing or acceptance details for the next slice.
- Build: a selected slice with enough acceptance detail to implement TDD-first.
- Review: a diff, PR, design, or implementation that must be checked against intent.
- Compound: completed work or learning that may be worth codifying.

If routing is ambiguous and the choice materially changes the output, ask one focused routing question.

## Output

- Chosen mode and why.
- The mode-specific output, using the matching `clarity-*` skill behavior.
- Any single next action or single focused question when human judgement is required.

## Rules

- Ticket is mandatory for deliverable work.
- Do not add ceremony for trivial work.
- Ask one focused question at a time.
- Keep implementation freedom while clarifying expected behavior.
- Use `skills/clarity-engineering/references/framework-summary.md` as the portable framework reference when needed.

