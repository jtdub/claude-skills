# Output file outline

The `python-references` skill reads this file at Stage 4. Use these headings verbatim in the
generated files. A fixed structure keeps successive runs diffable, so the user sees what changed in
Python rather than what changed in the wording.

If a source yields nothing for a section, keep the heading and write `No source found this run.`
Then record the gap in `INDEX.md`.

Every file except `INDEX.md` ends with `## Reviewer checklist`. That section holds five to ten
yes-or-no questions a reviewer runs against a diff. It is the last heading in the file.

---

## INDEX.md

```
# Python References

## Versions covered
## File map
## Sources
## Fetch failures
## Sources added this run
## Gaps
```

The versions section states the CPython stable version and the version of ruff, uv, mypy, pytest,
pydantic, typer, and pre-commit, each with the endpoint it came from, plus the generation date. The
file map is a table of file name, subject, and line count. Under Gaps, name each empty section and
why.

`INDEX.md` has no reviewer checklist.

---

## style.md

```
## Layout and line length
## Naming
## Imports
## Docstrings
## Comments
## Ruff default rule set
## Formatter behavior
## Reviewer checklist
```

The Ruff default rule set section is a table of prefix, rule set name, and rule count, plus the
total. Record the Ruff version beside it. Do not list all the rules.

---

## typing.md

```
## Annotate what
## Built-in generics
## Unions and optionals
## Type aliases and type parameters
## Protocols and structural typing
## Variables and class attributes
## Superseded and deferred syntax
## mypy strictness
## Reviewer checklist
```

Each PEP a section relies on gets its number and its live status. A PEP whose status is not `Final`
or `Active` carries a `**Superseded:**` or `**Draft:**` line instead of a rule.

---

## packaging.md

```
## pyproject.toml structure
## Build backend
## Project metadata
## Dependencies
## Dependency groups
## Version single-sourcing
## Lockfiles
## Publishing
## Reviewer checklist
```

---

## project-layout.md

```
## src layout
## Package and module names
## Entry points
## __main__ and __init__
## Tests, docs and data files
## Reviewer checklist
```

The src layout section states why src layout is the default choice, and what a flat layout breaks.

---

## testing.md

```
## Test layout and naming
## Fixtures
## Fixture scope and teardown
## conftest.py
## parametrize
## Markers
## tmp_path and file system tests
## monkeypatch
## Coverage
## Reviewer checklist
```

---

## errors-and-logging.md

```
## Exception hierarchy
## Which exception to raise
## Exception chaining
## Catching and re-raising
## Custom exceptions
## Logger creation
## Log levels
## Structured logging
## logging.config
## What never to log
## Reviewer checklist
```

---

## async.md

```
## Coroutines and tasks
## Running an event loop
## Task groups
## Cancellation
## Timeouts
## Synchronisation primitives
## Queues
## Blocking calls in async code
## Common pitfalls
## Reviewer checklist
```

The pitfalls section pairs each mistake with the correct form. Take them from the asyncio
development page, not from memory.

---

## pydantic.md

```
## Models
## Fields
## Types and coercion
## Validators
## model_config
## Serialization
## Settings
## Errors
## Reviewer checklist
```

Every rule is Pydantic v2. Mark a difference from v1 with a line that starts `**v1 vs v2:**`.

---

## cli.md

```
## Command structure
## argparse
## Typer
## Arguments and options
## Help text
## Exit codes
## Input and output streams
## Reviewer checklist
```

The exit codes section states the meaning of 0, 1, and 2, and what a command returns on a usage
error.

---

## security.md

```
## Running a subprocess
## Secrets and randomness
## Path traversal
## Deserialization and pickle
## YAML loading
## SQL and injection
## Input validation
## Dependencies
## Reviewer checklist
```

Each section names the concrete failure to look for, then gives the correct pattern. Put the wrong
form and the right form side by side.

---

## tooling.md

```
## Ruff configuration
## Ruff in CI
## mypy configuration
## mypy in CI
## pre-commit
## uv
## The pyproject.toml block
## Reviewer checklist
```

The `pyproject.toml` block section is one complete example that holds every key the file
recommends. It must be valid TOML, and it must come from the fetched documentation.
