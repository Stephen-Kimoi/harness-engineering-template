---
name: code-structure-cleanup
description: Use after an AI-built feature works but the code has duplicated mechanics, repeated API calls, or messy structure. Guides a cleanup pass that extracts reusable service-layer modules without changing behavior.
version: 1.0.0
author: David Ondrej / Michael Shimeles interview notes
license: MIT
metadata:
  hermes:
    tags: [agentic-engineering, refactor, service-layer, code-quality]
    related_skills: [agentic-engineering-workflow, service-layer-architecture]
---

# Code Structure Cleanup After Every Feature

## Overview

AI agents often take the easiest path: they create new functions instead of reusing existing ones. A feature can work while still leaving behind duplicated logic, inconsistent validation, repeated API calls, and code that future agents struggle to understand.

Run this cleanup pass after a feature works, not before.

## When to Use

- A feature works locally but the code feels duplicated or messy.
- The agent created similar helper functions in multiple files.
- You want future agents to pick up the codebase without confusion.
- You need a smaller, cleaner PR before review.

Do not use this as permission to redesign the whole app.

## What "Service Layer" Means

A service layer is a place for reusable mechanics:

- sending an email,
- streaming an AI response,
- creating a sandbox,
- validating a webhook,
- calling an external API,
- transforming a payload,
- parsing or normalizing data.

The UI/route/action decides **what** should happen. The service handles **how** it happens.

For the detailed composable-API pattern, see [`service-layer-architecture`](../service-layer-architecture/SKILL.md).

## Cleanup Prompt

```md
The feature is working. Now do a code-structure cleanup pass.

Goal:
- Find duplicated runtime mechanics, repeated API calls, repeated parsing, repeated validation, or repeated business logic.
- Move repeated mechanics into reusable service-layer functions/modules.
- Keep domain policy in the calling route/action/component.
- Do not change user-facing behavior.
- Keep the diff small.

Process:
1. Inspect the files touched by the feature.
2. Identify repeated logic and name the duplication clearly.
3. Propose the smallest service-layer extraction.
4. Implement it.
5. Run the relevant tests/typechecks.
6. Summarize exactly what got simpler.
```

## Good Outcome

Instead of 4 files each having their own slightly different `sendEmail()` logic, there is one tested email service that all 4 files call.

## Common Pitfalls

1. **Refactoring the whole app.** Keep the scope tied to the feature.
2. **Renaming everything.** Naming churn makes PRs hard to review.
3. **Mixing cleanup with a new feature.** Cleanup is a separate pass.
4. **Only formatting code.** Pretty code can still contain duplicated logic.
5. **Moving domain policy into services.** Services should handle mechanics, not business decisions.

## Verification Checklist

- [ ] User-facing behavior stayed the same.
- [ ] Repeated mechanics were actually reduced.
- [ ] Calling files became simpler.
- [ ] Relevant tests/typechecks ran.
- [ ] Diff stayed focused on the feature area.
