---
name: grep-loop-review-workflow
description: Use when you have a small PR or feature and want an agent to repeatedly fix review feedback until tests pass and the PR is merge-ready. Works with AI reviewers, Greptile-style review, or human feedback.
version: 1.0.0
author: David Ondrej / Michael Shimeles interview notes
license: MIT
metadata:
  hermes:
    tags: [agentic-engineering, code-review, pr, review-loop]
    related_skills: [agentic-engineering-workflow, code-structure-cleanup]
---

# Grep Loop Review Workflow

## Overview

This is an auto-research-style loop for code review:

1. Create a small PR.
2. Let a review tool, AI reviewer, or human inspect it.
3. Feed the review back to the coding agent.
4. Agent fixes the feedback.
5. Review again.
6. Repeat until the PR is clean and tests pass.

The loop works best when the PR is small and the success condition is clear.

## When to Use

- You have a small PR/feature ready for review.
- Review feedback is specific enough for an agent to act on.
- Tests or typechecks can confirm the fix.
- You want the agent to keep going until the review is clean.

Do not use this on massive PRs or unclear product decisions.

## Review-Fix Prompt

```md
Run a review-fix loop for this PR.

Inputs:
- Current branch: <branch-name>
- Review feedback: <paste feedback or point to reviewer output>
- Required end state: tests pass, reviewer issues resolved, no unrelated rewrites.

Rules:
1. Read the PR diff first.
2. Read the review feedback.
3. Fix only issues that are real and relevant to this PR.
4. Add or update tests for each bug fix when possible.
5. Run the relevant tests/typechecks.
6. Commit/push the fix if this workflow is allowed to push.
7. Stop only when the PR is clean or when blocked by a decision that needs a human.
```

## Pre-Flight Check

Before starting the loop, ask:

```md
Is this PR too large for a reliable review loop? If yes, suggest how to split it.
```

If the answer is yes, split the PR first.

## Human Guardrails

- Use the loop on small PRs.
- Reviewers can produce false positives.
- Agents can over-fix and rewrite unrelated code.
- A clean review is not proof the product is valuable; it only means this diff looks clean.

## Common Pitfalls

1. **Thousands of lines in one PR.** The reviewer and coding agent both lose accuracy.
2. **No tests.** The loop needs objective checks, not just vibes.
3. **Blindly accepting every review comment.** Some comments are wrong or irrelevant.
4. **No stop condition.** Define what "done" means before starting.

## Verification Checklist

- [ ] PR is small enough to review reliably.
- [ ] Agent read the diff before editing.
- [ ] Agent fixed only relevant issues.
- [ ] Tests/typechecks passed or blockers were stated.
- [ ] Final summary lists resolved review items.
