# Skills

This directory collects agentic engineering skills that operationalize the harness template's five subsystems. Each skill is a structured, copy-paste-ready workflow prompt — a playbook the agent follows to execute a specific class of task reliably.

---

## How skills relate to the harness

The harness template defines *what infrastructure to set up*. Skills define *how to operate inside that infrastructure*.

| Harness subsystem | Skill |
|-------------------|-------|
| **Instructions** | [`source-code-context`](./source-code-context/SKILL.md) — give the agent real source instead of outdated docs |
| **State** | [`code-structure-cleanup`](./code-structure-cleanup/SKILL.md), [`service-layer-architecture`](./service-layer-architecture/SKILL.md) — keep code legible across sessions |
| **Feedback** | [`grep-loop-review-workflow`](./grep-loop-review-workflow/SKILL.md) — run review loops until tests pass |
| **All subsystems** | [`agentic-engineering-workflow`](./agentic-engineering-workflow/SKILL.md) — the meta operating system for agentic development |

---

## Skills index

| Skill | When to reach for it |
|-------|----------------------|
| [agentic-engineering-workflow](./agentic-engineering-workflow/SKILL.md) | Starting a feature, MVP, or tool with an AI agent and need a full-session structure |
| [source-code-context](./source-code-context/SKILL.md) | Agent is hallucinating function names; point it at real source on disk |
| [code-structure-cleanup](./code-structure-cleanup/SKILL.md) | Feature works but leaves behind duplicated logic; run a cleanup pass |
| [grep-loop-review-workflow](./grep-loop-review-workflow/SKILL.md) | Small PR needs repeated review-fix cycles until merge-ready |
| [service-layer-architecture](./service-layer-architecture/SKILL.md) | Multiple callers duplicate the same operation; extract a composable service layer |

---

## Skill relationships

```
agentic-engineering-workflow  (meta — use for full-session structure)
├── source-code-context        stage 3: give the agent real source before coding
├── code-structure-cleanup     stage 5: cleanup pass after the feature works
│   └── service-layer-architecture  (detailed pattern for extracting service layers)
└── grep-loop-review-workflow  stage 6: review-fix loop until PR is clean
```

`agentic-engineering-workflow` references all four supporting skills by name in its `related_skills` metadata. Pull individual skills in at the stage they cover rather than running them all upfront.

---

## How to use a skill

1. Open the relevant `SKILL.md`.
2. Copy the starter prompt from the **Copy-Paste Starter Prompt** or equivalent section.
3. Fill in the angle-bracket placeholders.
4. Paste into your agent session.

Skills compose: use `agentic-engineering-workflow` as the session operating system and swap in the focused skills at each stage.
