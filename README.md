# claude-skills

Skills, agents, rules and the global `CLAUDE.md` for [Claude Code](https://claude.com/claude-code),
kept in git and installed into `~/.claude` by symlink.

## Layout

The repo mirrors the `~/.claude` layout, so installation is a direct mapping.

```
skills/<skill-name>/SKILL.md   ->  ~/.claude/skills/<skill-name>
agents/<agent-name>.md         ->  ~/.claude/agents/<agent-name>.md
rules/<rule-name>.md           ->  ~/.claude/rules/<rule-name>.md
home/<file>                    ->  ~/.claude/<file>
```

`home/` maps to `~/.claude` itself, for a file that has no subdirectory.

## Install

```bash
./install.sh --dry-run   # see what would be linked
./install.sh             # link it
```

The script creates symlinks, so an edit here takes effect immediately and `git pull` updates your
live setup. It never overwrites a real file. If a symlink already points somewhere else, the script
skips it and tells you; `--force` replaces those.

Start a new Claude Code session afterward to pick up the changes.

## What is here

### `nautobot-references` (skill)

Fetches the current [Nautobot](https://docs.nautobot.com) documentation and source, then writes
best-practice and design-pattern reference files to `~/.claude/references/nautobot/`.

It re-fetches on every run. Page discovery goes through the live documentation sitemap rather than a
hardcoded URL list, so new documentation pages are picked up without editing the skill. The generated
files record the Nautobot version they describe, the date, and the source URL behind each rule.

Output:

```
~/.claude/references/nautobot/
├── INDEX.md                  version, file map, sources, gaps
├── app-structure.md          layout, NautobotAppConfig, PLUGINS_CONFIG, changelog
├── public-api.md             the nautobot.apps.* surface and the import rule
├── models.md                 base classes, natural keys, migrations, model checklist
├── views-and-ui.md           NautobotUIViewSet, UI Component Framework, tables, forms, filters
├── rest-api.md               serializers, viewsets, versioning, filtering
├── jobs-and-integrations.md  jobs, hooks, secrets providers, validators, datasources
├── testing.md                nautobot.apps.testing case classes, factories, CI
├── security.md               secrets, permissions, sensitive variables, rendering
└── versioning-migration.md   v2 to v3 changes, deprecations, version pinning
```

Run it:

```
/nautobot-references
```

Re-run it after a Nautobot release, or whenever the references look stale.

### `nautobot-review` (agent)

Reviews a Nautobot app pull request, branch, or working tree.

It loads the references above, runs the `code-review` and `security-review` skills, then adds a
Nautobot-specific pass: public API imports, model base classes and migrations, `NautobotUIViewSet`
usage, serializer and filterset and form and table coverage, `nautobot.apps.testing` usage, job
registration and sensitive variables, version pins, and changelog fragments.

It reports back in the session. It does not edit files, commit, push, or comment on a pull request.

Ask for it by name:

```
Use the nautobot-review agent on PR 42
Use the nautobot-review agent on this branch
```

The agent stops and tells you to run `/nautobot-references` first if the references are missing. A
review without them is an ordinary code review.

### `rules/` (rules)

Standing preferences that apply to every project, written as checkable rules rather than prose.

| Rule | What it settles |
| --- | --- |
| `python-comments-and-docstrings.md` | No `#` comments outside tool directives. Terse Google-style docstrings. All documentation in Simplified Technical English (ASD-STE100). |
| `pull-request-descriptions.md` | Use the repository's PR template. Terse bullets. No session link, no remaining-work section, no code-standard section. `Closes: DNE` when no issue exists. |
| `changelog-fragments.md` | Written for an end user, not a developer. At most three items, one per line, terse, in Simplified Technical English. |
| `engineering-workflow.md` | Plan before code across modules. One branch and one PR per unit of work. Tests before API and UI. The spec wins over the prompt. |
| `verify-against-source.md` | Read the installed package source or the live documentation when unsure about an API. Say which source you read. |
| `prose-style.md` | No em dashes anywhere. Simplified Technical English for every word written. Cut a sentence that changes nothing. |
| `session-hygiene.md` | Append a dated lesson to `.claude/LESSONS.md` after a non-trivial task. Propose a `CLAUDE.md` edit, but do not apply it. |

`home/CLAUDE.md` below imports each rule with an `@` line. A project's own `CLAUDE.md` overrides a
rule where the two disagree.

Claude Code also loads `~/.claude/rules/*.md` on its own, so a rule here reaches every session by
two paths. Source: <https://code.claude.com/docs/en/memory>, read 2026-09-02. The `@` lines stay
for now, because they also fix the load order.

### `home/CLAUDE.md`

The global `CLAUDE.md`, installed to `~/.claude/CLAUDE.md`. It imports every rule, so each one loads
in every session:

```
@~/.claude/rules/python-comments-and-docstrings.md
@~/.claude/rules/pull-request-descriptions.md
@~/.claude/rules/changelog-fragments.md
@~/.claude/rules/engineering-workflow.md
@~/.claude/rules/verify-against-source.md
@~/.claude/rules/prose-style.md
@~/.claude/rules/session-hygiene.md
```

Add an `@` line here when you add a rule. Keep the line even though `~/.claude/rules/` also loads on
its own. It fixes the load order, and it keeps the whole rule set readable in one file.

## Usage order

1. Install: `./install.sh`
2. Generate the references once: `/nautobot-references`
3. Review Nautobot work with the `nautobot-review` agent.
