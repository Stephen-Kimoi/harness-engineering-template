---
name: source-code-context
description: Use when an AI coding agent is guessing API names or framework behavior from incomplete docs. Shows how to provide local source-code references so the agent searches the real implementation before coding.
version: 1.0.0
author: David Ondrej / Michael Shimeles interview notes
license: MIT
metadata:
  hermes:
    tags: [agentic-engineering, context-engineering, source-code, ai-coding]
    related_skills: [agentic-engineering-workflow]
---

# Source Code as Agent Context

## Overview

Code is often the best source of truth. Docs can be outdated, examples can be incomplete, and blog posts can lag behind the current API. When an agent has access to the actual repo/package source, it can search for real function names, types, examples, and edge cases.

Use this skill to stop the agent from guessing.

## When to Use

- You are integrating a package, SDK, API client, framework, or open-source tool.
- The agent keeps hallucinating functions that do not exist.
- Docs are weak, stale, or too abstract.
- You want the agent to follow the package's actual internal patterns.

Do not paste an entire repo into chat. Put the source on disk and point the agent to it.

## Setup

1. Identify the package/repo you are using.
2. Add the repo/source into a clearly named folder in your project, for example:
   - `reference/repos/github.com/company/project`
   - `open-source/repos/github.com/company/project`
3. Add a short instruction in `AGENTS.md`, `CLAUDE.md`, or your harness memory:

```md
When working with <library/tool>, reference the local source under:
`reference/repos/github.com/company/project`.
Do not guess API names. Search the source first, then implement.
```

## Feature Prompt Template

```md
Build <feature>. We use <library/tool>.

Before coding:
1. Search `reference/repos/github.com/company/project` for the correct API and patterns.
2. Identify the files/functions/examples you used as reference.
3. Implement only the minimal service function and one calling route/component.
4. Keep the diff small.
5. Explain which source files you referenced.
```

## Example

```md
We need to integrate Daytona sandboxes into this app.
Reference the local Daytona source under `reference/repos/github.com/daytonaio/daytona`.
Find the current SDK pattern for creating a sandbox and running a command.
Then implement only the minimal service function and one calling route.
```

## Common Pitfalls

1. **Dumping too much context into chat.** This bloats the context window. Let the agent search files on disk.
2. **Trusting old docs over current code.** Fast-moving packages change quickly.
3. **Letting the agent install alternatives.** If it cannot find the API, make it search the source before adding new dependencies.
4. **No path convention.** Use a predictable folder name so every future agent knows where references live.

## Verification Checklist

- [ ] Reference source exists in a stable folder.
- [ ] Agent was explicitly told where to search.
- [ ] Agent reported which files/functions it referenced.
- [ ] No random replacement package was installed without approval.
- [ ] The implementation matches current source-code patterns.
