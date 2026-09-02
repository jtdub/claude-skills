---
name: verify-against-source
description: Read the installed package source or the live documentation when unsure about an API. Never guess from training data. State which source you read.
---

# Verify against the source

## Read the source, do not recall it

When you are unsure how a library API behaves, read one of these before you write the call:

1. The installed package source in the project environment.
2. The live documentation for the version the project pins.

Do not answer from training data. A library changes between releases, and your memory of it does
not carry a version number.

## Say what you read

When you rely on an API you looked up, name the source in the same message. Give the file path and
the symbol, or the URL and the date you fetched it.

- Good: "`ruff format` takes a path argument. Source: `docs.astral.sh/ruff/formatter/`, read
  2026-09-02."
- Bad: "`ruff format` takes a path argument."

## When you cannot check

If you cannot reach the source, say so. State the assumption you made instead. Do not present a
guess as a fact.
