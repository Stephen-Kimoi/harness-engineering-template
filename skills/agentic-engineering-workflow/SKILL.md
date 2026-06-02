---
name: agentic-engineering-workflow
description: Use when building software with AI agents and you need a serious end-to-end workflow instead of vibe coding. Covers harness choice, context discipline, cleanup, review loops, launch pressure, and security basics.
version: 1.0.0
author: David Ondrej / Michael Shimeles interview notes
license: MIT
metadata:
  hermes:
    tags: [agentic-engineering, ai-coding, workflow, micky-podcast]
    related_skills: [source-code-context, code-structure-cleanup, grep-loop-review-workflow]
---

# Agentic Engineering Workflow

## Overview

Use this as the high-level operating system for building with AI agents. The core idea is simple: stay in charge, keep the agent's context focused, and give it tight feedback loops.

This is not "ask the AI to build everything and hope." It is a workflow where the human decides the outcome, the agent does the mechanical work, and tests/reviews keep the result honest.

## When to Use

- You are building an MVP, feature, internal tool, or AI-assisted product.
- You want a repeatable AI coding workflow instead of random prompting.
- You are non-technical or early technical and need simple rules for staying in control.
- You are using Cursor, Claude Code, Codex, Hermes, or another coding harness.

Do not use this for one-off tiny edits where a normal direct prompt is enough.

## Workflow

1. **Pick the strongest harness/model you can access.** The harness is the wrapper around the model: file search, terminal, browser, tools, system prompt, and project memory. The model matters, but the harness determines what the model can actually do.

2. **Keep the task small.** Ask for one feature, one fix, or one reviewable unit at a time. If a plan is too large, ask the agent to split it into smaller PR-sized chunks.

3. **Give source code as context when docs are not enough.** If you are using a package, SDK, framework, or open-source tool, put its source in a reference folder and tell the agent to search it before coding. See [`source-code-context`](../source-code-context/SKILL.md).

4. **Build the minimal feature first.** Do not refactor the whole app while building the feature. Get the smallest working version running.

5. **Run a cleanup pass.** After the feature works, ask the agent to find duplicated runtime mechanics and move them into reusable service-layer modules. See [`code-structure-cleanup`](../code-structure-cleanup/SKILL.md) and [`service-layer-architecture`](../service-layer-architecture/SKILL.md).

6. **Run a review-fix loop.** Use tests, typechecks, and AI/human review. Feed review feedback back into the coding agent. Keep fixing until the PR is clean or a human decision is needed. See [`grep-loop-review-workflow`](../grep-loop-review-workflow/SKILL.md).

7. **Launch earlier than feels comfortable.** Do not hide forever behind "one more feature." A semi-functional MVP with feedback beats a perfect private project.

8. **Apply security guardrails.** Use 2FA, a password manager, avoid young packages, and ask your agent to check whether your project is exposed when a package/security issue trends.

## Copy-Paste Starter Prompt

```md
We are going to build this using an agentic engineering workflow.

Rules:
1. Keep the change small and reviewable.
2. Search the existing code before creating new abstractions.
3. If using a package/framework, reference its local source or official repo before guessing APIs.
4. Build the minimal working version first.
5. After it works, run a code-structure cleanup pass.
6. Run relevant tests/typechecks.
7. Summarize what changed, what was tested, and what still needs human judgment.

Task:
<describe the feature or fix here>
```

## Security Guardrails

- Never install a package that is less than 14 days old unless a human explicitly approves it.
- Use 2FA through an authenticator app, not SMS.
- Use a password manager.
- Do not paste secrets into prompts or screenshots.
- When a package breach trends, ask the agent to inspect your local projects for that package/version.

## Common Pitfalls

1. **Letting the agent think for you.** The agent is a worker, not the product owner.
2. **Overloading context.** More context is not always better. Give the exact files/folders it needs.
3. **Huge PRs.** Review loops break down when the diff is thousands of lines.
4. **No cleanup pass.** Working code can still be duplicated and hard for future agents to debug.
5. **Never launching.** Waiting for perfect is how competitors ship before you.

## Verification Checklist

- [ ] Task was split into a small reviewable unit.
- [ ] Agent searched relevant existing code before editing.
- [ ] External package/framework behavior was checked against source or official docs.
- [ ] Feature works locally.
- [ ] Cleanup pass removed obvious duplication.
- [ ] Tests/typechecks ran or the reason they could not run is stated.
- [ ] Security-sensitive changes were explicitly reviewed.
