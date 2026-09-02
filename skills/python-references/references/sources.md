# Source map

The `python-references` skill reads this file at Stage 2. It says how to discover the pages for
each source, and what to pull from GitHub.

Most sources carry a live index: a sitemap, a JSON API, or a directory listing. Read that index on
every run. Do not hardcode a page list where an index exists. A new documentation page must arrive
without a skill edit.

Every URL below returned HTTP 200 on 2026-09-02.

---

## Fixed URL block

These sources publish no machine-readable index. This block is the only hardcoded page list in the
skill. Edit it here when a source moves.

| URL | Feeds | Why it is fixed |
|---|---|---|
| `https://pre-commit.com/` | `tooling.md` | The site is one `index.mako` template, not markdown. There is no sitemap and no page list |
| `https://docs.astral.sh/ruff/default-rules/` | `style.md` | A generated page. It is in the sitemap but not in the `docs/` directory of the repository |
| `https://docs.astral.sh/ruff/settings/` | `tooling.md` | A generated page, same reason |
| `https://docs.astral.sh/uv/reference/settings/` | `tooling.md`, `packaging.md` | A generated page. `uv/docs/reference/` holds no `settings.md` |

Fetch these four with `WebFetch`. Every other source below is discovered live and fetched as raw
text.

---

## Versions

Read the version of each tool before you fetch anything. The generated files record it.

| What | Endpoint | Field |
|---|---|---|
| CPython stable | `https://endoflife.date/api/python.json` | `[0].cycle` and `[0].latest` |
| A tool release | `https://pypi.org/pypi/<package>/json` | `info.version` |

Use PyPI for ruff, uv, mypy, pytest, pydantic, typer, and pre-commit.

Do not use `https://api.github.com/repos/<repo>/releases/latest` for a version. It returned nothing
for `python/mypy` and `python/cpython` on 2026-09-02. PyPI returned a version for every tool.

---

## Discovery

| Source | Live index | Approx. entries |
|---|---|---|
| PEPs | `https://peps.python.org/api/peps.json` | every PEP, with `title`, `status`, and `url` |
| CPython library | `api.github.com/repos/python/cpython/contents/Doc/library?ref=main` | 355 |
| Packaging User Guide | `api.github.com/repos/pypa/packaging.python.org/contents/source/guides?ref=main` | 33 |
| pytest how-to | `api.github.com/repos/pytest-dev/pytest/contents/doc/en/how-to?ref=main` | 24 |
| mypy | `api.github.com/repos/python/mypy/contents/docs/source?ref=master` | 40 |
| Pydantic concepts | `api.github.com/repos/pydantic/pydantic/contents/docs/concepts?ref=main` | 19 |
| Ruff hand-written pages | `api.github.com/repos/astral-sh/ruff/contents/docs?ref=main` | 17 |
| OWASP cheat sheets | `api.github.com/repos/OWASP/CheatSheetSeries/contents/cheatsheets?ref=master` | 200 |
| Ruff full page list | `https://docs.astral.sh/ruff/sitemap.xml` | 990, most of them one rule each |
| uv | `https://docs.astral.sh/uv/sitemap.xml` | 84 |
| Typer | `https://typer.tiangolo.com/sitemap.xml` | 73 |

A Read the Docs sitemap lists versions, not pages. `packaging.python.org/sitemap.xml`,
`mypy.readthedocs.io/sitemap.xml`, and `docs.pytest.org/sitemap.xml` each hold one to fifteen
version entries and no page list. Use the GitHub contents API for those three.

Scan each index for a page that this file does not name. If you find one that is clearly relevant,
include it and record the addition in `INDEX.md` under "Sources added this run".

---

## Fetch paths

Fetch raw text from GitHub, not rendered pages. Raw text gives the exact source with its code
blocks intact, and costs one `curl` instead of one page render.

| Source | Raw base |
|---|---|
| PEPs | `https://raw.githubusercontent.com/python/peps/main/peps/pep-NNNN.rst` |
| CPython library | `https://raw.githubusercontent.com/python/cpython/<tag>/Doc/library/<page>.rst` |
| Packaging User Guide | `https://raw.githubusercontent.com/pypa/packaging.python.org/main/source/guides/<page>.rst` |
| pytest | `https://raw.githubusercontent.com/pytest-dev/pytest/main/doc/en/how-to/<page>.rst` |
| mypy | `https://raw.githubusercontent.com/python/mypy/master/docs/source/<page>.rst` |
| Pydantic | `https://raw.githubusercontent.com/pydantic/pydantic/main/docs/concepts/<page>.md` |
| Ruff | `https://raw.githubusercontent.com/astral-sh/ruff/main/docs/<page>.md` |
| uv | `https://raw.githubusercontent.com/astral-sh/uv/main/docs/<path>.md` |
| Typer | `https://raw.githubusercontent.com/fastapi/typer/master/docs/<path>.md` |
| coverage.py | `https://raw.githubusercontent.com/nedbat/coveragepy/master/doc/<page>.rst` |
| pytest-cov | `https://raw.githubusercontent.com/pytest-dev/pytest-cov/master/docs/<page>.rst` |
| OWASP | `https://raw.githubusercontent.com/OWASP/CheatSheetSeries/master/cheatsheets/<name>.md` |

The PEP number pads to four digits: PEP 8 is `pep-0008.rst`.

Pin CPython to the stable tag from the version step, such as `v3.14.7`. Every other repository
tracks its default branch, because its documentation ships with the tool rather than with a
release.

---

## Per-file sources

### `style.md`

| Source | Path |
|---|---|
| PEP 8 | `peps/pep-0008.rst` |
| PEP 257 | `peps/pep-0257.rst` |
| Ruff default rules | the fixed URL block |
| Ruff formatter | `ruff/docs/formatter.md` |
| Ruff linter | `ruff/docs/linter.md` |

Ruff's default rule set held 213 rules across 34 rule sets on 2026-09-02. Do not fetch a page for
each one. Read the default rules page once, record the rule sets as a table of prefix, name, and
count, and record the total. A later Ruff release that changes the default then shows up as a diff.

Fetch an individual `docs.astral.sh/ruff/rules/<name>/` page only when a rule needs explaining.
Fetch no more than ten of them in a run.

### `typing.md`

| Source | Path |
|---|---|
| PEP 484, 526, 604, 695 | `peps/pep-0484.rst` and so on |
| PEP 563, 612, 646, 696 | the same, for the parts a reviewer meets |
| `typing` module | `cpython/Doc/library/typing.rst` |
| mypy strictness | `mypy/docs/source/command_line.rst`, `config_file.rst`, `existing_code.rst` |

Read the `status` field of each PEP from the JSON API. PEP 563 was `Superseded` on 2026-09-02. A
superseded PEP gets a `**Superseded:**` line, not a rule.

### `packaging.md`

| Source | Path |
|---|---|
| PEP 517, 518, 621, 735 | `peps/pep-0517.rst` and so on |
| Packaging User Guide | `guides/writing-pyproject-toml.rst`, `tool-recommendations.rst`, `single-sourcing-package-version.rst`, `modernize-setup-py-project.rst` |
| uv | `uv/docs/concepts/projects/config.md`, `layout.md`, `dependencies.md`, `uv/docs/concepts/configuration-files.md`, `uv/docs/guides/projects.md` |

### `project-layout.md`

| Source | Path |
|---|---|
| src layout | `packaging.python.org/source/discussions/src-layout-vs-flat-layout.rst` |
| Entry points | `guides/creating-command-line-tools.rst`, `packaging.python.org/source/specifications/entry-points.rst` |
| `__main__` | `cpython/Doc/library/__main__.rst` |

### `testing.md`

| Source | Path |
|---|---|
| pytest how-to | every `.rst` under `doc/en/how-to`, and `doc/en/reference/fixtures.rst` |
| coverage.py | `coveragepy/doc/config.rst`, `coveragepy/doc/source.rst` |
| pytest-cov | `pytest-cov/docs/config.rst` |

Cover fixtures, `parametrize`, markers, `conftest.py`, `tmp_path`, and `monkeypatch` at minimum.

Coverage belongs to `coverage.py`, not to pytest. Read its own documentation for the
`[tool.coverage.*]` keys in `pyproject.toml`.

### `errors-and-logging.md`

| Source | Path |
|---|---|
| Exception hierarchy and chaining | `cpython/Doc/library/exceptions.rst`, `cpython/Doc/tutorial/errors.rst` |
| Logging | `cpython/Doc/library/logging.rst`, `logging.config.rst`, `logging.handlers.rst`, `cpython/Doc/howto/logging.rst`, `logging-cookbook.rst` |
| OWASP | `cheatsheets/Logging_Cheat_Sheet.md`, `Logging_Vocabulary_Cheat_Sheet.md` |

### `async.md`

| Source | Path |
|---|---|
| asyncio | `cpython/Doc/library/asyncio-task.rst`, `asyncio-runner.rst`, `asyncio-sync.rst`, `asyncio-queue.rst`, `asyncio-exceptions.rst`, `asyncio-dev.rst` |

`asyncio-dev.rst` holds the pitfalls. Cover tasks, cancellation, timeouts, task groups, and the
common mistakes.

### `pydantic.md`

| Source | Path |
|---|---|
| Pydantic concepts | every `.md` under `pydantic/docs/concepts`, at minimum `models.md`, `validators.md`, `config.md`, `serialization.md`, `fields.md`, `types.md` |
| Settings | `pydantic/docs/concepts/pydantic_settings.md` |

Pydantic v2 only. Do not write a v1 rule. Flag a v1 pattern under a `**v1 vs v2:**` line.

### `cli.md`

| Source | Path |
|---|---|
| argparse | `cpython/Doc/library/argparse.rst`, `cpython/Doc/howto/argparse.rst` |
| Typer | `typer/docs/tutorial/**`, `typer/docs/index.md` |
| Exit codes | `cpython/Doc/library/sys.rst`, `os.rst` for `os.EX_*` |

### `security.md`

| Source | Path |
|---|---|
| subprocess | `cpython/Doc/library/subprocess.rst` |
| secrets | `cpython/Doc/library/secrets.rst` |
| pickle | `cpython/Doc/library/pickle.rst` |
| paths | `cpython/Doc/library/pathlib.rst`, `os.path.rst` |
| YAML | `https://raw.githubusercontent.com/yaml/pyyaml/main/lib/yaml/__init__.py` for the `load` and `safe_load` contract |
| OWASP | `cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.md`, `Deserialization_Cheat_Sheet.md`, `Injection_Prevention_Cheat_Sheet.md`, `Input_Validation_Cheat_Sheet.md`, `Secrets_Management_Cheat_Sheet.md`, `SQL_Injection_Prevention_Cheat_Sheet.md`, `File_Upload_Cheat_Sheet.md` |

### `tooling.md`

| Source | Path |
|---|---|
| Ruff | `ruff/docs/configuration.md`, `linter.md`, `formatter.md`, `integrations.md`, plus the settings page from the fixed URL block |
| mypy | `mypy/docs/source/config_file.rst`, `command_line.rst`, `running_mypy.rst` |
| pre-commit | the fixed URL block |
| uv | `uv/docs/guides/integration/pre-commit.md`, `uv/docs/concepts/**`, plus the uv settings page from the fixed URL block |

Record the `pyproject.toml` key for each setting, not the command line flag, where both exist.

---

## Rate limits

The unauthenticated GitHub API allows 60 requests per hour. Each directory listing costs one
request, and there are eight of them. Every page fetch goes to `raw.githubusercontent.com`, which
does not carry the same limit. If `gh` is authenticated, use `gh api` in place of `curl` on
`api.github.com`.
