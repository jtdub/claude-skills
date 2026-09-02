---
name: python-comments-and-docstrings
description: No `#` comments in Python code. Terse Google-style docstrings. All documentation in Simplified Technical English (ASD-STE100).
---

# Python comments and docstrings

## No `#` comments

Do not write `#` comments in Python code. Make the code self-explanatory instead.

If a comment feels necessary, do one of these:

1. Rename the variable, function, or constant to say what the comment said.
2. Extract the block into a small named function or a named intermediate variable.
3. Move the reason into the docstring of the enclosing function, class, or module.
4. Delete it. Most comments restate the code or record history that git already holds.

Never write these:

- Section banners (`# --- Helpers ---`).
- Restatements of the next line (`# increment the counter`).
- Commented-out code. Delete it.
- Narrative rationale that reads like a design memo.
- Sphinx attribute comments (`#: ...`). Use an attribute docstring instead.

### Directives are not comments

Keep these. They change tool behavior and are not prose:

- `# noqa: <rule>`
- `# pylint: disable=<rule>`
- `# type: ignore`
- `# pragma: no cover`
- `# fmt: off` and `# fmt: on`
- The shebang line and the encoding line.

Write a directive bare, with no explanation after it. If the reason matters, put
it in the docstring.

### Attribute documentation

Document a module or class constant with a string literal below it, not with `#:`.

```python
MAX_RETRIES = 3
"""Attempts before the call is abandoned."""
```

Prefer a name that needs no string at all.

## Terse Google-style docstrings

Use the Google convention. Keep every docstring short.

- Write a one-line summary. Use the imperative mood. End it with a period.
- Add a body only when the summary cannot carry the meaning.
- Keep the body to three sentences or fewer.
- Add `Args:`, `Returns:`, `Raises:`, and `Yields:` only when the signature is
  not obvious. Do not repeat the type annotations.
- Do not describe the implementation. Describe the contract.
- Do not include usage examples unless the caller cannot guess the call shape.

```python
def resolve_binding(agent, tool):
    """Return the tool name this agent calls the tool by.

    Args:
        agent: The parent agent.
        tool: The tool to bind.

    Returns:
        The unique name allocated for the binding.

    Raises:
        ValidationError: If no name is free.
    """
```

A trivial function needs one line only:

```python
def is_enabled(self):
    """Return True if the record is active."""
```

## Write all documentation in Simplified Technical English

Write every docstring, every Markdown document, every help string, and every
user-facing message in ASD-STE100 Simplified Technical English.

### Sentences

- Use a maximum of 20 words in an instruction.
- Use a maximum of 25 words in a description.
- Give only one instruction in each sentence.
- Use the active voice. Write "The Job writes the record", not "The record is
  written by the Job".
- Use simple tenses only: past, present, and future. Do not use the present
  perfect.
- Do not use the `-ing` form of a verb as a noun or an adjective. Write "Before
  you start the sync", not "Before starting the sync".

### Words

- Use one word for one meaning. Do not use a synonym for variation.
- Use simple, common words. Prefer "use" over "utilize", "start" over
  "initiate", "make sure" over "ensure", "show" over "display", "about" over
  "approximately", "enough" over "sufficient", "also" over "in addition".
- Do not use slang, idioms, or figures of speech.
- Do not use a noun cluster of more than three nouns. Break it apart with a
  preposition.
- Keep technical names exact. Class names, function names, field names, and
  file names are permitted as written.

### Paragraphs and structure

- Keep one topic in each paragraph.
- Use a maximum of six sentences in each paragraph.
- Use a vertical list to make complex text simple.
- Put a warning before the instruction it applies to, not after.
- In a warning, give the risk first and the instruction second. Example:
  "WARNING: This deletes every checkpoint. Make a backup before you continue."

### What this excludes

Do not apply Simplified Technical English to these. Keep them exact:

- Code blocks, shell commands, and file paths.
- Quoted output and quoted error text.
- Test method names. A test name states what the test proves.

## Applying this to existing code

When you edit a file that breaks these rules, fix the code you touch. Do not
rewrite the whole file unless you are asked to.
