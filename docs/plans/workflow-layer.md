# Workflow layer plan

This plan extends `claude-skills` from a Nautobot toolkit into a general engineering workflow
layer. It covers five pull requests: rules, a `python-references` skill, skills, agents, and hooks.

`skills/nautobot-references` and `agents/nautobot-review` do not change. The new
`skills/python-references` is a sibling of the Nautobot skill, not a replacement.

## 1. Verified Claude Code facts

I checked every fact below against the live documentation on **2026-09-02**. I did not rely on
training data.

The documentation moved. `https://docs.claude.com/en/docs/claude-code/overview` returns a 301 to
`https://code.claude.com/docs/en/overview`. The page index is
`https://code.claude.com/docs/llms.txt`. Each page also serves raw markdown at its `.md` URL, for
example `https://code.claude.com/docs/en/hooks.md`.

### 1.1 Skill frontmatter

Source: `https://code.claude.com/docs/en/skills.md`, checked 2026-09-02.

| Fact | Value |
| --- | --- |
| File | `SKILL.md`, frontmatter between `---` markers, opening `---` on line 1 |
| `name` | Optional. In a personal or user skill it sets the display label only. The command name comes from the directory name |
| `description` | Recommended. Claude reads it to decide when to load the skill |
| Other fields used here | `when_to_use`, `argument-hint`, `allowed-tools`, `disable-model-invocation` |
| Fields available but not used here | `arguments`, `user-invocable`, `disallowed-tools`, `model`, `effort`, `context`, `agent`, `background`, `hooks`, `paths`, `shell`, `metadata`, `license`, `compatibility` |
| String substitutions | `$ARGUMENTS`, `$0`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_SESSION_ID}` |

The existing `nautobot-references` skill uses `name` and `description` only. The new skills match
that, and add `argument-hint` where a skill takes an argument.

### 1.2 Agent frontmatter

Source: `https://code.claude.com/docs/en/sub-agents.md`, checked 2026-09-02.

| Field | Required | Note |
| --- | --- | --- |
| `name` | yes | Lowercase and hyphens. Cannot contain `:` |
| `description` | yes | When Claude delegates to the agent |
| `tools` | no | Inherits every subagent tool when omitted |
| `disallowedTools` | no | Removed from the inherited list |
| `model` | no | `sonnet`, `opus`, `haiku`, `fable`, a full model ID, or `inherit` |
| `color` | no | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |

`agents/nautobot-review.md` uses `name`, `description`, `model`, and `color`. All four are
current. The three new agents use the same four fields.

### 1.3 The `@` import syntax in `CLAUDE.md`

Source: `https://code.claude.com/docs/en/memory.md`, checked 2026-09-02.

- A `CLAUDE.md` imports a file with `@path/to/file`. Relative and absolute paths both work.
- Imports resolve relative to the file that holds the line, not to the working directory.
- Imports nest to a maximum depth of four hops.
- Import parsing skips code spans and fenced code blocks. `` `@README` `` stays literal.
- An imported file loads at launch and stays in context. An import saves no context.

`home/CLAUDE.md` already uses this syntax. It is current.

### 1.4 A finding that contradicts this repository

Source: `https://code.claude.com/docs/en/memory.md`, section "User-level rules", checked
2026-09-02.

> Personal rules in `~/.claude/rules/` apply to every project on your machine.

Claude Code **does** load `~/.claude/rules/*.md` on its own now. `README.md` and `CLAUDE.md` in
this repository both state the opposite. See the ambiguity in section 5.

### 1.5 The `hooks` schema in `settings.json`

Source: `https://code.claude.com/docs/en/hooks.md`, checked 2026-09-02.

**Shape.** `hooks` is a top-level key in `settings.json`. It nests three levels: an event name, a
list of matcher groups, and a list of hook handlers inside each group.

```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [ { "type": "command", "command": "..." } ] }
    ]
  }
}
```

**Locations.** `~/.claude/settings.json` applies to every project. Hook entries merge across the
settings levels. They do not replace each other.

**Event names used in this plan.** Each one comes from the event table on that page.

| Event | Fires | Can exit 2 block it? |
| --- | --- | --- |
| `PreToolUse` | Before a tool call | Yes. Blocks the tool call |
| `PostToolUse` | After a tool call succeeds | No. Exit 2 shows stderr to Claude; the tool already ran |
| `SessionStart` | When a session begins or resumes | No. Exit 2 shows stderr to the user only |
| `PostCompact` | After compaction completes | No. It has no decision control at all |

**Matcher semantics.**

- `"*"`, `""`, or an omitted matcher matches everything.
- A matcher of letters, digits, `_`, `-`, spaces, `,`, and `|` is an exact string, or a list of
  exact strings separated by `|` or `,`.
- A matcher with any other character is an unanchored JavaScript regular expression.
- `PreToolUse` and `PostToolUse` match on the **tool name**, never on a file path.
- `SessionStart` matches on the source: `startup`, `resume`, `clear`, `compact`, or `fork`.
- `PreCompact` and `PostCompact` match on `manual` or `auto`.

**The `if` field.** A handler can carry `if` with one permission rule, such as `"Edit(*.py)"`. It
holds exactly one rule. There is no `&&` or list syntax. One `if` rule matches one tool only, so
`Edit` and `Write` need separate handlers. The documentation calls the filter best-effort. This
plan therefore checks the file extension inside each script and does not use `if`.

**stdin JSON contract.** Command hooks read the event JSON on stdin. Common fields are
`session_id`, `transcript_path`, `cwd`, `permission_mode`, and `hook_event_name`. Tool events add
`tool_name`, `tool_input`, and `tool_use_id`. `PostToolUse` adds `tool_response`. File tool paths
in `tool_input.file_path` are always absolute, with the platform's separators.

There is no environment variable that carries the event data. The scripts read stdin.

**stdout JSON contract.**

- Claude Code parses stdout as JSON when it starts with `{` and ends with `}`.
- Universal fields: `continue`, `stopReason`, `systemMessage`, `terminalSequence`.
- `hookSpecificOutput` needs a `hookEventName` field set to the event name.
- `additionalContext` inside `hookSpecificOutput` puts a string into Claude's context.
- Output strings are capped at 10,000 characters. Longer output goes to a file.
- For `SessionStart`, plain-text stdout also reaches Claude's context directly. No JSON needed.

**Exit code meaning.**

| Exit code | Meaning |
| --- | --- |
| 0 | Success. Print JSON on stdout for structured control |
| 2 | Blocking error. On a blocking event it blocks whatever the JSON says |
| any other | Non-blocking error for most events. The action proceeds |

The documentation warns that exit code 1 does **not** block. A policy hook must use exit 2.

**Path placeholders.** Only `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, and
`${CLAUDE_PLUGIN_DATA}` exist. There is no placeholder for the home directory.

A handler runs in **exec form** when `args` is present, with no shell, so `$HOME` does not expand.
It runs in **shell form** when `args` is absent, through `sh -c`, so `$HOME` does expand.

These hooks live in `~/.claude/hooks/`, which no placeholder names. This plan therefore uses shell
form with a quoted `"$HOME/.claude/hooks/<name>.sh"`. The scripts take no arguments and read
stdin, so shell form costs nothing.

**Timeouts.** The default is 600 seconds for a command hook. The requirement is under two seconds,
so each entry sets `"timeout": 10` as a guard.

**Disabling.** `"disableAllHooks": true` in a settings file turns every hook off. There is no
supported way to disable one hook while it stays in the configuration. To remove one hook, delete
its entry.

**The compaction event.** `PostCompact` exists, but it has no decision control, and Claude Code
discards its `systemMessage` and `continue` fields. Its stdout goes to the debug log. It therefore
**cannot** put material back into context.

`SessionStart` fires with `source: "compact"` after auto or manual compaction, and its stdout does
reach Claude. The re-print after compaction is therefore a `SessionStart` hook with a matcher that
covers `compact`, not a `PostCompact` hook. This plan uses one script for both.

**Tool names.** Source: `https://code.claude.com/docs/en/tools-reference.md`, checked 2026-09-02.
The file-writing tools are `Edit`, `Write`, and `NotebookEdit`. `MultiEdit` does not appear in the
reference and is not used.

### 1.6 Python source discovery, verified by probe

Every URL below returned HTTP 200 on 2026-09-02.

| Source | Live discovery | Result |
| --- | --- | --- |
| PEPs | `https://peps.python.org/api/peps.json` | 200, every PEP with `number`, `title`, `status`, `url` |
| CPython library | `api.github.com/repos/python/cpython/contents/Doc/library` | 355 entries |
| Packaging User Guide | `api.github.com/repos/pypa/packaging.python.org/contents/source/guides` | 33 entries |
| pytest | `api.github.com/repos/pytest-dev/pytest/contents/doc/en/how-to` | 24 entries |
| mypy | `api.github.com/repos/python/mypy/contents/docs/source` | 40 entries |
| Pydantic | `api.github.com/repos/pydantic/pydantic/contents/docs/concepts` | 19 entries |
| Typer | `https://typer.tiangolo.com/sitemap.xml` | 73 pages |
| Ruff | `https://docs.astral.sh/ruff/sitemap.xml` | 990 pages |
| uv | `https://docs.astral.sh/uv/sitemap.xml` | 84 pages |
| OWASP | `api.github.com/repos/OWASP/CheatSheetSeries/contents/cheatsheets` | 200 |
| pre-commit | none. The site is `index.mako`, not markdown | the one hardcoded URL |

Read the Docs sitemaps list versions, not pages. `packaging.python.org/sitemap.xml`,
`mypy.readthedocs.io/sitemap.xml`, and `docs.pytest.org/sitemap.xml` each hold one to fifteen
version entries and no page list. The GitHub contents API replaces them.

Raw source fetches, all 200:

- `raw.githubusercontent.com/python/cpython/main/Doc/library/asyncio-task.rst`
- `raw.githubusercontent.com/python/peps/main/peps/pep-0008.rst`
- `raw.githubusercontent.com/pydantic/pydantic/main/docs/concepts/models.md`
- `raw.githubusercontent.com/pytest-dev/pytest/main/doc/en/how-to/fixtures.rst`
- `raw.githubusercontent.com/python/mypy/master/docs/source/command_line.rst`
- `raw.githubusercontent.com/pypa/packaging.python.org/main/source/guides/writing-pyproject-toml.rst`
- `raw.githubusercontent.com/astral-sh/ruff/main/docs/configuration.md`
- `raw.githubusercontent.com/fastapi/typer/master/docs/index.md`

Version endpoints. `api.github.com/repos/<r>/releases/latest` is unreliable: `python/mypy` and
`python/cpython` returned nothing. The PyPI JSON API is reliable and returned a version for every
tool on 2026-09-02: ruff 0.16.5, uv 0.12.9, mypy 2.3.1, pytest 9.1.1, pydantic 2.13.5, typer
0.27.2, pre-commit 4.6.2. `https://endoflife.date/api/python.json` returned CPython 3.14.7.

### 1.7 The local machine

- `jq` is at `/usr/local/bin/jq`, version 1.6. The merge jq must run on 1.6.
- `~/.claude/settings.json` exists, holds nine keys, and has **no** `hooks` key. This confirms the
  decision never to symlink `settings.json`.

## 2. Files by pull request

### PR 1: rules

Branch `feat/workflow-rules`. Conventional Commit `feat(rules): add four workflow rules`.

| File | Action | Note |
| --- | --- | --- |
| `rules/engineering-workflow.md` | add | Six checkable rules. About 22 lines |
| `rules/verify-against-source.md` | add | Two checkable rules. About 15 lines |
| `rules/prose-style.md` | add | Three checkable rules. About 18 lines |
| `rules/session-hygiene.md` | add | Two checkable rules. About 20 lines |
| `home/CLAUDE.md` | edit | Four new `@` lines |
| `README.md` | edit | Four new rows in the `rules/` table |

Each rule carries the same frontmatter shape as the three existing rules: `name` matching the file
name, and a one-line `description`. Each stays under 25 lines, as instructed.

### PR 2: python-references skill

Branch `feat/python-references`. Conventional Commit `feat(skills): add python-references skill`.

| File | Action | Note |
| --- | --- | --- |
| `skills/python-references/SKILL.md` | add | Five stages, the same shape as `nautobot-references` |
| `skills/python-references/references/sources.md` | add | Discovery per source, plus the fixed URL block |
| `skills/python-references/references/outline.md` | add | The exact headings for the twelve output files |
| `README.md` | edit | A `python-references` section with the output tree |

The skill splits the procedure from the data, the same way the Nautobot skill does. `SKILL.md`
holds the stages. `sources.md` and `outline.md` hold what changes.

Output goes to `~/.claude/references/python/`. Twelve files: `INDEX.md`, `style.md`, `typing.md`,
`packaging.md`, `project-layout.md`, `testing.md`, `errors-and-logging.md`, `async.md`,
`pydantic.md`, `cli.md`, `security.md`, `tooling.md`.

Each file starts with a frontmatter block that records the version, the generation date, and the
sources that fed it. Each file ends with a `## Reviewer checklist` section.

The fixed URL block in `sources.md` is one clearly marked table. It holds only the sources with no
live index: the pre-commit page, and any PEP the skill names directly. Every other source is
discovered live.

### PR 3: skills

Branch `feat/workflow-skills`. Conventional Commit `feat(skills): add five workflow skills`.

| File | Action |
| --- | --- |
| `skills/plan/SKILL.md` | add |
| `skills/slice/SKILL.md` | add |
| `skills/adr/SKILL.md` | add |
| `skills/retro/SKILL.md` | add |
| `skills/bootstrap/SKILL.md` | add |
| `README.md` | edit, a `skills` section with one paragraph for each |

Each skill states four things under fixed headings: `## Inputs`, `## Steps`, `## Outputs`, and
`## What this skill refuses to do`. Each skill that writes Python or prose reads
`~/.claude/rules/` and, when it exists, `~/.claude/references/python/`.

`bootstrap` scaffolds a src-layout repository with `pyproject.toml`, Ruff, mypy, pytest, coverage,
`pre-commit`, a GitHub Actions workflow, `CLAUDE.md`, empty `docs/adr/` and `docs/plans/`, and
`.claude/LESSONS.md`. It asks for the package name and a one-line description, and nothing else.

### PR 4: agents

Branch `feat/workflow-agents`. Conventional Commit `feat(agents): add three read-only reviewers`.

| File | Action |
| --- | --- |
| `agents/plan-reviewer.md` | add |
| `agents/drift-auditor.md` | add |
| `agents/test-gap-reviewer.md` | add |
| `README.md` | edit, one section for each agent |

All three follow the structure of `agents/nautobot-review.md`: frontmatter, a `## Constraints`
block, numbered phases, and a report format sorted into `MUST FIX`, `SHOULD FIX`, `CONSIDER`, and
`FOLLOW UP`. All three are read-only. None edits, commits, pushes, or comments on a pull request.

`drift-auditor` and `test-gap-reviewer` need a diff, so both may run `gh pr checkout` and both
return to the starting branch, the same exception `nautobot-review` takes.

### PR 5: hooks

Branch `feat/hooks`. Conventional Commit `feat(hooks): add five hooks and a settings merge`.

| File | Action | Note |
| --- | --- | --- |
| `hooks/ruff-format.sh` | add | `PostToolUse`, formats a written `.py` file |
| `hooks/no-em-dash.sh` | add | `PostToolUse`, fails on an em dash in a `.md` file |
| `hooks/block-dangerous-bash.sh` | add | `PreToolUse`, blocks a destructive or secret-touching command |
| `hooks/session-context.sh` | add | `SessionStart`, prints LESSONS and ADR titles |
| `home/hooks.json` | add | The fragment `install.sh` merges |
| `install.sh` | edit | See section 3 |
| `README.md` | edit | A `hooks` section, plus how to disable one |

Four scripts cover five behaviors. `session-context.sh` serves both the session start and the
re-print after compaction, because `SessionStart` fires with `source: "compact"`. See section 1.5.

Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`, is executable, reads its
JSON from stdin, and finishes well under two seconds.

## 3. The `install.sh` changes

Three changes.

**3.1 Link `hooks/`.** `hooks/` holds `.sh` files, not `.md` files and not directories. `install_dir`
selects entries with a hard-coded rule: `skills` takes directories, everything else takes `*.md`.
Add a third branch so `hooks` takes `*.sh`, then call `install_dir hooks`.

```bash
if [ "$kind" = "skills" ]; then
    ...directories...
elif [ "$kind" = "hooks" ]; then
    for e in "$src_dir"/*.sh; do
        [ -f "$e" ] && entries+=("$e")
    done
else
    ...*.md...
fi
```

`link_entry` needs no change. It links a file the same way whatever the extension is.

**3.2 Merge `home/hooks.json`.** A new `install_hooks_json` function runs after `install_home`.

`home/` is linked file by file, and `install_home` links every file in it. `hooks.json` must not be
linked into `~/.claude/`, so `install_home` skips it by name.

The merge rules:

- If `jq` is missing, print `install.sh: jq is required to merge hooks.json` on stderr and exit 3.
- If `~/.claude/settings.json` is missing, create it as `{}` first. In `--dry-run`, say so and
  change nothing.
- If `~/.claude/settings.json` holds invalid JSON, print the error and stop. Do not overwrite it.
- Merge only into the `hooks` key. Leave every other key exactly as it is.
- Identify this repository's handlers by the marker string `/.claude/hooks/` inside the `command`
  field. Drop every existing handler that carries the marker, then add the current set.
- Never touch a handler without the marker. That is how a hook the user wrote survives.
- Drop a matcher group that ends up with an empty `hooks` array, and drop an event that ends up
  with no groups. That is how a hook removed from `home/hooks.json` disappears.
- Write to a temporary file, then move it into place. A failed `jq` never truncates the settings.
- `--dry-run` prints the resulting `hooks` key and writes nothing.
- `--force` is not needed to merge, because the merge never destroys another tool's data. It stays
  accepted and changes nothing here, which keeps the flag consistent.

The jq program, written for jq 1.6:

```bash
MARKER="/.claude/hooks/"
jq --slurpfile fragment "$REPO_DIR/home/hooks.json" --arg marker "$MARKER" '
  def strip_ours:
    map(.hooks |= map(select((.command // "") | contains($marker) | not)))
    | map(select((.hooks | length) > 0));
  def merge_event($mine; $ours):
    reduce $ours[] as $group ($mine;
      if any(.[]; .matcher == $group.matcher)
      then map(if .matcher == $group.matcher
               then .hooks += $group.hooks
               else . end)
      else . + [$group] end);
  . as $settings
  | ($fragment[0].hooks // {}) as $new
  | .hooks = (
      (($settings.hooks // {}) | with_entries(.value |= strip_ours))
      | reduce ($new | keys_unsorted[]) as $event (.;
          .[$event] = merge_event((.[$event] // []); $new[$event]))
      | with_entries(select((.value | length) > 0))
    )
' "$SETTINGS" > "$TMP"
```

**3.3 Report the merge.** The summary line already counts links. Add one line that says whether
`settings.json` changed, so `--dry-run` output shows the whole effect.

## 4. The hook set

| Event | Matcher | Script | What it does |
| --- | --- | --- | --- |
| `PostToolUse` | `Edit\|Write\|NotebookEdit` | `ruff-format.sh` | Runs `ruff format` and `ruff check --fix` on the written file. Exits 0 in every other case |
| `PostToolUse` | `Edit\|Write` | `no-em-dash.sh` | Exits 2 with the line numbers when a `.md` file holds an em dash |
| `PreToolUse` | `Bash` | `block-dangerous-bash.sh` | Exits 2 when the command matches a forbidden pattern |
| `SessionStart` | `startup\|resume\|clear\|compact` | `session-context.sh` | Prints `.claude/LESSONS.md` in full and the ADR titles. On `compact`, adds the reminder to re-read `CLAUDE.md` |

Design notes, each tied to section 1.5:

- The matcher filters the tool name only. Each script reads `tool_input.file_path` from stdin and
  checks the extension itself. A file with the wrong extension exits 0 at once.
- `ruff-format.sh` exits 0 when `ruff` is not installed. A missing formatter is not a defect in the
  file that was written.
- `no-em-dash.sh` uses `PostToolUse`, which cannot block. Exit 2 is still correct: it shows the
  stderr to Claude, which is what "fail with a message listing the line numbers" asks for.
- `block-dangerous-bash.sh` uses exit 2, not exit 1. Exit 1 does not block.
- `block-dangerous-bash.sh` blocks `git push --force`, `git push -f`, `rm -rf`, and any path that
  matches `.env`, `*.pem`, `*_rsa`, or `credentials`.
- `session-context.sh` prints plain text on stdout. `SessionStart` puts plain-text stdout into
  Claude's context, so the script needs no JSON.
- `session-context.sh` reads `cwd` from the stdin JSON, not `$PWD`. The two can differ.

## 5. Ambiguities, with the reading I propose

**5.1 `~/.claude/rules/` now loads on its own.** The live documentation says personal rules in
`~/.claude/rules/` apply to every project. `README.md` and `CLAUDE.md` in this repository both say
Claude Code does not load them, and that `home/CLAUDE.md` is what turns them on. If both paths are
now active, every rule loads twice and costs double the context.

*Proposed reading.* Add the four `@` lines as the prompt instructs, because the prompt is explicit.
Add nothing else in PR 1. Raise the duplicate-load question separately once the five pull requests
are open, because removing the `@` lines changes how the three existing rules load and belongs in
its own change. I will note the doc URL and the check date in the README edit.

**5.2 "After Write or Edit on a `.py` file".** A hook matcher cannot filter on a file path. Only
the tool name is available.

*Proposed reading.* Match the tool names, and check the extension inside the script. This is more
reliable than the `if` field, which the documentation calls best-effort.

**5.3 "After context compaction, if such an event exists".** `PostCompact` exists, but it has no
decision control, and its stdout goes to the debug log. It cannot return material to context.

*Proposed reading.* Use `SessionStart` with the `compact` source, which does reach context. Record
in the README why `PostCompact` is not used.

**5.4 The `hooks/` directory name.** `install_dir` maps a directory name one to one onto
`~/.claude`. `~/.claude/hooks/` is not a directory Claude Code reads on its own. It is only a place
to keep scripts that `settings.json` names by path.

*Proposed reading.* Link it anyway, exactly as the prompt asks. It gives the scripts one stable
absolute path, `$HOME/.claude/hooks/<name>.sh`, that works on any machine and needs no rewrite at
install time.

**5.5 "the Ruff rule documentation for the default rule set".** Ruff's default rule set is `E4`,
`E7`, `E9`, and `F`. The sitemap holds 990 pages, most of them one rule each.

*Proposed reading.* Fetch the settings page and the rules index, resolve the current default set
from them, and fetch only the pages for the rules in that set. Record the resolved set in
`INDEX.md`, so a later Ruff release that changes the default is visible in the diff.

**5.6 "Runs the full check suite" in `/slice`.** No project here defines a check suite.

*Proposed reading.* The skill reads the commands from the project: the `pre-commit` configuration,
the CI workflow, then `pyproject.toml`. If it finds none, it stops and asks. It does not guess.

**5.7 PR 5 wants the `/retro` output in its own description.** `/retro` writes to
`.claude/LESSONS.md` in the working directory. This repository has no `.claude/` directory.

*Proposed reading.* Create `.claude/LESSONS.md` in this repository as part of PR 5, and commit it.
The file is the artifact `session-hygiene.md` and `/retro` both name, so this repository should
carry one.

## 6. What I will not do

- I will not change `skills/nautobot-references` or `agents/nautobot-review`.
- I will not merge any pull request.
- I will not write an em dash in any file.
- I will not add a `settings.json` to `home/`.
