---
name: session-hygiene
description: Append a dated lesson to .claude/LESSONS.md after any non-trivial task. Propose a CLAUDE.md edit for a durable lesson, but do not apply it without approval.
---

# Session hygiene

## Record the lesson

At the end of any non-trivial task, append an entry to `.claude/LESSONS.md` in the project. Create
the file if it does not exist. Write three lines under a dated heading:

```markdown
## 2026-09-02

- **Went wrong:** The hook matcher filtered the tool name, not the file path.
- **Surprised me:** `PostCompact` cannot put text back into context.
- **Next time:** Read the event table before you choose an event.
```

Use the absolute date. Never write "today" or "last week".

A task is non-trivial when it took more than one round of correction, or when it crossed more than
one file.

## Promote a durable lesson

If a lesson applies past this task, propose an edit to the project `CLAUDE.md` in the same turn.
Show the exact text you would add, and say which lesson it comes from.

Do not apply the edit. Wait for approval. A `CLAUDE.md` line loads in every session, so the cost of
a wrong one is high.
