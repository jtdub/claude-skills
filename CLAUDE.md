# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This repository holds Claude Code skills, agents and rules as version-controlled markdown. It contains
no application code. `install.sh` symlinks each entry into `~/.claude`, so an edit here changes the live
Claude Code setup immediately.

Content is prompt text. The "code" is the instructions an agent follows, so a change is correct only
if an agent can act on it.

## Commands

```bash
./install.sh --dry-run   # print the links, change nothing
./install.sh             # create the symlinks
./install.sh --force     # replace a symlink that points elsewhere
CLAUDE_DIR=/tmp/fake ./install.sh --dry-run   # test the installer against a throwaway target
```

There is no build, no lint, and no test suite. To test a change, install it, start a new Claude Code
session, and run the skill or the agent.

`install.sh` never overwrites a real file. It only replaces symlinks, and only with `--force`.

## Layout contract

The directory names in this repository must match the `~/.claude` names, because `install.sh` maps
them one to one:

```
skills/<name>/SKILL.md   ->  ~/.claude/skills/<name>      (directory symlink)
agents/<name>.md         ->  ~/.claude/agents/<name>.md   (file symlink)
rules/<name>.md          ->  ~/.claude/rules/<name>.md    (file symlink)
```

`install_dir` in `install.sh` links skill *directories*; every other kind links *.md files*. A new
top-level kind (for example `commands/`) needs a new `install_dir` call and a matching entry rule.

The `name:` field in a skill's, agent's or rule's YAML frontmatter must match its directory or file
name.

## How the two pieces fit together

`skills/nautobot-references` and `agents/nautobot-review` are one system, joined by a file contract
rather than by code:

1. The skill fetches Nautobot documentation and writes ten files to `~/.claude/references/nautobot/`.
2. The agent reads those files, then judges a diff against them.

The agent stops if the directory is missing. It maps diff paths to reference files with a table in
its Phase 1. If you rename, add, or remove a reference file, change three places together:

- the output table in `skills/nautobot-references/SKILL.md` (Stage 4)
- the headings block in `skills/nautobot-references/references/outline.md`
- the "Diff touches / Also read" table in `agents/nautobot-review.md`

The README also lists the ten files. Keep it in step.

## Skill internals

`SKILL.md` holds the procedure. The two files in `references/` hold data the procedure reads at run
time, so the procedure stays stable while the data changes:

- `sources.md` — which sitemap patterns to select and which GitHub paths to pull. Stage 2 reads it.
- `outline.md` — the exact section headings for each generated file. Stage 4 reads it.

Fixed headings make successive runs diffable. Put new source patterns in `sources.md` and new
sections in `outline.md`. Do not inline either into `SKILL.md`.

Two rules the skill depends on. Do not weaken them:

- **Always fetch fresh.** No run trusts a previous run's output or its recorded version.
- **Discover pages from the live sitemap.** No hardcoded page list, so new documentation pages arrive
  without a skill edit.

Fetching uses raw markdown from the tagged release on `raw.githubusercontent.com`, not rendered docs
pages, and not the unauthenticated GitHub API where it can be avoided. The API allows 60 requests per
hour; `raw.githubusercontent.com` does not carry the same limit.

## Agent constraints

`nautobot-review` reports only. It does not edit, commit, push, or comment on a pull request. The one
write it makes is `gh pr checkout`, and it returns to the starting branch. Keep these constraints in
any edit to that agent.

Every convention finding must cite a reference file and a diff line. A finding with no reference
behind it is dropped.

## Rules

`rules/` holds standing preferences that apply across projects. A rule is not a skill and not an
agent: nothing invokes it, and Claude Code does not load `~/.claude/rules/` on its own. A rule takes
effect only when something points at it, such as a `CLAUDE.md` import, a memory file, or a session
that names the file.

Write a rule the way the other files here are written: checkable statements, not prose. State what
not to do beside what to do. Give an example where the wrong choice is tempting.

Keep each rule to one subject. A rule that settles two unrelated questions is two rules.

## Writing style for skills and agents

Match the existing files:

- Write checkable rules, not prose. A reviewer holds a rule against a diff and answers yes or no.
- Use tables for a mapping, a stage heading for a step.
- State what not to do next to what to do, where the wrong choice is tempting.
