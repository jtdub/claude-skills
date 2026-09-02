---
name: prose-style
description: No em dashes in any prose. Simplified Technical English for all documentation, comments, PR text and changelog text. Cut a sentence that changes nothing.
---

# Prose style

This rule covers every word you write: documentation, docstrings, code comments, commit messages,
pull request text, changelog fragments, and your replies.

## No em dashes

Do not write an em dash. Use a comma, a colon, parentheses, or a second sentence.

```text
Wrong: The hook blocks the call — the tool never runs.
Right: The hook blocks the call, so the tool never runs.
```

This applies to generated files too. A file you write for another agent to read follows the same
rule.

## Simplified Technical English

Write in ASD-STE100. [[python-comments-and-docstrings]] holds the full rules. The short form:

- Use a maximum of 20 words in an instruction, and 25 in a description.
- Give one instruction in each sentence.
- Use the active voice and simple tenses.
- Use one word for one meaning. Do not reach for a synonym.

Keep code blocks, shell commands, file paths, and quoted output exact. This rule does not touch
them.

## Cut it

Delete a sentence that does not change what the reader does. Preambles, restatements, and closing
summaries all fail that test.
