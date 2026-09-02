---
name: python-references
description: Fetch the current Python, Ruff, mypy, pytest, uv, Pydantic and Typer documentation, then write Python best-practice reference files to ~/.claude/references/python/. Use when the user asks to create, refresh, or update Python references, or asks what Python's conventions, typing rules, packaging layout, or tooling configuration are.
---

# Python References

Build a set of reference files that record how Python code is written, typed, packaged, tested and
configured. Other agents and skills read these files.

**Always fetch fresh.** Python and its tools release often. Do not reuse a previously generated
file, and do not trust a version number written in an existing `INDEX.md`. Re-run every stage on
every invocation.

## Output

Default output directory: `~/.claude/references/python/`

If the user names a different directory, use that instead. Create the directory if it does not
exist.

## Stage 1 - Establish the versions

Read `references/sources.md` in this skill directory. Its Versions section names the endpoints.

Fetch the CPython stable version from `https://endoflife.date/api/python.json`. Read `[0].cycle`
and `[0].latest`.

Fetch each tool version from `https://pypi.org/pypi/<package>/json` and read `info.version`. Do
this for ruff, uv, mypy, pytest, pydantic, typer, and pre-commit.

```bash
for p in ruff uv mypy pytest pydantic typer pre-commit; do
    v=$(curl -sf "https://pypi.org/pypi/$p/json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["info"]["version"])')
    echo "$p $v"
done
```

Do not read a version from `api.github.com/repos/<repo>/releases/latest`. It returns nothing for
several of these repositories.

Record every version. Stage 4 writes them into each file's header.

## Stage 2 - Discover sources

Read the Discovery section of `references/sources.md`. It names a live index for each source.

Read every index on this run. Do not hardcode a page list where an index exists. A new
documentation page must arrive without a skill edit.

Three sources publish no index. `sources.md` holds them in one block titled "Fixed URL block".
Fetch those three with `WebFetch`. They are the only hardcoded pages in this skill.

Read the PEP index once and keep it. It carries the live status of each PEP:

```bash
curl -sf https://peps.python.org/api/peps.json -o peps.json
```

A PEP whose `status` is not `Final` or `Active` does not become a rule. Stage 4 marks it instead.

Scan each index for a page that `sources.md` does not name. If you find one that is clearly
relevant to how Python code is written, include it and record the addition in `INDEX.md` under
"Sources added this run".

## Stage 3 - Fetch

**Fetch raw text from GitHub, not rendered pages.** Each source ships its documentation as
reStructuredText or markdown in its own repository. Reading that source gives you the exact text,
with its code blocks and admonitions intact, and costs one `curl` instead of one page render.

The Fetch paths section of `sources.md` gives the raw base for each source. Pin CPython to the
stable tag from Stage 1. Every other repository tracks its default branch, because its
documentation ships with the tool rather than with a release.

Fetch in bulk with a single shell loop, not one call per page:

```bash
OUT=$(mktemp -d)
while read -r url; do
    dest="$OUT/$(echo "$url" | sed 's|.*/||')"
    curl -sf "$url" -o "$dest" || echo "FAILED $url" >> "$OUT/failures.txt"
done < selected-urls.txt
```

Then read the downloaded files. Expect 90 to 130 of them.

Use `WebFetch` only for the three pages in the fixed URL block, and for a page whose raw path
returns 404.

Keep every failure in a list. Stage 5 reports them. Never drop a topic silently.

### The Ruff rule set

Ruff's default rule set held 213 rules across 34 rule sets on 2026-09-02. Do not fetch a page for
each one.

Read the default rules page once. Record the rule sets as a table of prefix, name, and count, plus
the total, and record the Ruff version beside it. A later release that changes the default then
shows up as a diff.

Fetch an individual rule page only when a rule needs explaining. Fetch no more than ten in a run.

## Stage 4 - Write the reference files

Read `references/outline.md` in this skill directory. It fixes the section headings for each output
file. Follow it, so successive runs produce a diffable structure instead of a re-organized
document.

Write these twelve files. Overwrite whatever is there.

| File | Covers |
|---|---|
| `INDEX.md` | Python version, tool versions, generation date, file map, full source list, fetch failures, gaps |
| `style.md` | layout, naming, imports, docstrings, the Ruff default rule set, formatter behavior |
| `typing.md` | what to annotate, built-in generics, unions, type parameters, protocols, mypy strictness |
| `packaging.md` | `pyproject.toml`, build backend, metadata, dependencies, dependency groups, lockfiles |
| `project-layout.md` | src layout, package names, entry points, `__main__`, where tests and data go |
| `testing.md` | layout, fixtures, `conftest.py`, `parametrize`, markers, `tmp_path`, `monkeypatch`, coverage |
| `errors-and-logging.md` | exception hierarchy, chaining, custom exceptions, loggers, levels, `logging.config` |
| `async.md` | coroutines, tasks, task groups, cancellation, timeouts, queues, blocking calls, pitfalls |
| `pydantic.md` | v2 models, fields, validators, `model_config`, serialization, settings |
| `cli.md` | command structure, `argparse`, Typer, help text, exit codes, streams |
| `security.md` | `subprocess`, secrets, path traversal, pickle, YAML, injection, input validation |
| `tooling.md` | Ruff, mypy, pre-commit and uv configuration keys, and the CI invocation for each |

Start every file with this header block:

```markdown
---
python_version: 3.14.7
tool_versions:
  ruff: 0.16.5
  mypy: 2.3.1
generated: 2026-09-02
sources:
  - https://peps.python.org/pep-0008/
  - https://raw.githubusercontent.com/python/cpython/v3.14.7/Doc/library/typing.rst
---
```

Use the real versions and date from Stage 1. List only the versions and the sources that fed that
file.

### How to write the body

Write checkable rules, not documentation prose. A reviewer must be able to hold a rule against a
diff and decide yes or no.

- Good: "Annotate every public function parameter and its return. A private helper may omit them."
- Bad: "Python supports optional type hints."

Further rules:

- Give a short code example for each pattern. Take it from the fetched documentation. Do not invent
  an example.
- Put the source URL next to each non-obvious rule, so a reviewer can check the claim.
- Give the version behind a rule that depends on one. Write `**3.12+:**` before a rule that needs a
  recent Python, and `**v1 vs v2:**` before a Pydantic difference.
- Never write a rule that no fetched source supports. If a topic returned no usable source, leave
  the section empty and record the gap in `INDEX.md`.
- Keep each file under about 400 lines. An agent loads several of these at once.
- Do not write an em dash anywhere in a generated file.

### The reviewer checklist

End every file except `INDEX.md` with a `## Reviewer checklist` section. Put five to ten yes-or-no
questions in it. Each question must be answerable from a diff alone.

- Good: "Does every public function carry a return annotation?"
- Bad: "Is the typing good?"

## Stage 5 - Report

Print:

1. The Python version and each tool version the references describe.
2. The output directory, and each file with its line count.
3. Every source URL that failed, with the reason.
4. Any section left empty for lack of a source.
5. Any source added this run that `sources.md` does not list, so the user can fold it in.
6. The Ruff default rule set total, so a change from the last run is visible.
