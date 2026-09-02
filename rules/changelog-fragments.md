---
name: changelog-fragments
description: A changelog fragment is written for an end user: at most three bullets, terse, in Simplified Technical English.
---

# Changelog fragments

A fragment is a file in the project's fragment directory, usually `changes/`, named
`<number>.<type>` for towncrier. The number is the issue the change closes, or the
pull request when no issue exists.

## The reader is an end user, not a developer

Write for the person who installs the release and operates it. They did not read the
diff, they will not read the source, and they do not know your class names.

Ask of each item: **what does this person do differently now?** If the answer is
nothing, the item does not belong in a fragment.

| Write about | Not about |
| --- | --- |
| A new page, field, Job, or command they can use | A new module, mixin, or helper |
| A setting they add or change | A refactor behind that setting |
| Behavior they will notice | The implementation that produces it |
| An upgrade step they must take | The migration file that takes it |
| A fixed symptom they reported | The cause in the code |

Name a thing an end user can see: a page, a setting key, a Job name, a command. Use a
class name only when the user reads that name on a screen or in configuration.

## Three items, no more

Put at most **three** bullets in a fragment. Choose the three the reader most needs
before they upgrade.

Rank by effect on the reader, in this order:

1. What they must do, or what stops working.
2. What is new that they would otherwise not find.
3. What changed in behavior they already depend on.

Drop everything else. The pull request and the diff hold the rest. A fragment is a
release note, not a summary of the work.

## One item per line, never a paragraph

Write one item on one line. A blank line or a wrapped line splits the item in two.

```
Added an Agents section under AI Tools, where you build an agent from a model, a prompt, and the tools it may call.
Added AI Tools to Git repositories, so a repository supplies tools the same way it supplies Jobs.
Added a Prune Agent Threads Job. Nothing else deletes the conversation state an agent leaves behind.
```

- Put one fact in each item. An item with two facts is two items, or one of them goes.
- Start the item with the verb the type calls for: Added, Changed, Fixed, Removed.

### Do not add your own bullet marker

A towncrier template usually emits the `-` itself and splits the fragment on newlines.
A `*` or `-` you type becomes a second marker, so the release note reads
`- [#9](...) - * Added ...`.

Render a draft before you commit, and read the output:

```bash
towncrier build --version <next> --draft
```

Add a marker only when the draft shows the template supplies none.

## Simplified Technical English

Write every item in ASD-STE100, the same as
[[python-comments-and-docstrings]] requires.

- Use a maximum of 25 words in an item.
- Use the active voice. Write "The Job deletes the state", not "The state is deleted".
- Use simple tenses. Do not use the present perfect.
- Use one word for one meaning. Do not reach for a synonym.
- Do not use the `-ing` form of a verb as a noun.

## Never write these

- **An internal change.** A rename, a refactor, or a new private helper is not a
  release note, however much work it was.
- **A design memo.** No rationale beyond a short clause, and no history.
- **A rewrite of the pull request description.** That one is for a reviewer. This one
  is for an operator.
- **Marketing words.** No "comprehensive", "robust", or "powerful".

## One fragment for each type

Split a change across the types the project declares, such as `added`, `changed`,
`fixed`, `security`, `dependencies`, or `documentation`. The three-item limit applies
to each fragment on its own, not to the pull request as a whole.
