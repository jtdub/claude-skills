---
name: nautobot-references
description: Fetch the current Nautobot documentation and source, then write Nautobot best-practice and design-pattern reference files to ~/.claude/references/nautobot/. Use when the user asks to create, refresh, or update Nautobot references, or asks what Nautobot's app design patterns, conventions, or best practices are.
---

# Nautobot References

Build a set of reference files that record how Nautobot apps are designed and written. Other
agents read these files. The `nautobot-review` agent depends on them.

**Always fetch fresh.** Nautobot releases often. Do not reuse a previously generated file, and do not
trust a version number written in an existing `INDEX.md`. Re-run every stage on every invocation.

## Output

Default output directory: `~/.claude/references/nautobot/`

If the user names a different directory, use that instead. Create the directory if it does not exist.

## Stage 1 — Establish the version

Fetch `https://api.github.com/repos/nautobot/nautobot/releases/latest` and read `tag_name` and
`published_at`. This is the Nautobot version the references describe. Record it.

Also note the previous major line. Nautobot v3 changed the UI significantly from v2, and many
community apps still target v2. The references must cover v3 as primary and flag v2 differences.

## Stage 2 — Discover sources

Read `references/sources.md` in this skill directory. It holds the sitemap path patterns and the
GitHub paths to pull.

Fetch the sitemap and filter it with those patterns:

```bash
curl -s https://docs.nautobot.com/projects/core/en/stable/sitemap.xml \
  | grep '<loc>' | sed 's/.*<loc>//;s|</loc>||' \
  | sed 's|https://docs.nautobot.com/projects/core/en/stable/||'
```

Filter from the live sitemap. Do not hardcode a page list. New documentation pages must be picked up
without editing this skill.

Scan the filtered list for app-relevant sections that `sources.md` does not name. If you find one,
include it and record the addition in `INDEX.md` under "Sources added this run".

## Stage 3 — Fetch

**Fetch the documentation as raw markdown, not as rendered pages.** The Nautobot docs are built with
mkdocs from markdown that lives in the same repository, tagged with each release. Reading the
markdown gives you the exact source, with its code blocks and admonitions intact, and costs one
`curl` instead of one page render.

Map each sitemap path to a markdown path under
`https://raw.githubusercontent.com/nautobot/nautobot/<tag>/nautobot/docs/`, using the tag from
Stage 1:

| Sitemap path | Markdown path |
|---|---|
| `development/core/best-practices/` | `nautobot/docs/development/core/best-practices.md` |
| `development/apps/` | `nautobot/docs/development/apps/index.md` |
| `development/apps/api/models/` | `nautobot/docs/development/apps/api/models/index.md` |

The rule: strip the trailing slash and append `.md`. If that returns 404, the page is a section
index, so append `/index.md` instead.

Fetch them in bulk with a single shell loop rather than one call per page:

```bash
TAG=v3.2.3
BASE="https://raw.githubusercontent.com/nautobot/nautobot/$TAG/nautobot/docs"
OUT=$(mktemp -d)
while read -r path; do
    p="${path%/}"
    dest="$OUT/$(echo "$p" | tr '/' '_').md"
    curl -sf "$BASE/$p.md" -o "$dest" \
      || curl -sf "$BASE/$p/index.md" -o "$dest" \
      || echo "FAILED $p" >> "$OUT/failures.txt"
done < selected-paths.txt
```

Then read the downloaded files. Expect 60 to 90 of them.

Fall back to `WebFetch` on the docs.nautobot.com URL only for a page whose markdown both paths miss.

Read the `nautobot/apps/*.py` modules the same way, straight from `raw.githubusercontent.com`, to get
each module's `__all__` tuple.

Keep every failure in a list. Stage 5 reports them. Never drop a topic silently.

## Stage 4 — Write the reference files

Read `references/outline.md` in this skill directory. It fixes the section headings for each output
file. Follow it, so successive runs produce a diffable structure instead of a re-organized document.

Write these ten files. Overwrite whatever is there.

| File | Covers |
|---|---|
| `INDEX.md` | version, generation date, file map, full source list, fetch failures, sources added this run |
| `app-structure.md` | cookiecutter layout, `NautobotAppConfig`, entry point, `PLUGINS_CONFIG`, towncrier changelog |
| `public-api.md` | the `nautobot.apps.*` module surface and what each exports; the rule against internal imports |
| `models.md` | model base classes, natural keys, querysets, migrations, GraphQL, global search, django-admin |
| `views-and-ui.md` | `NautobotUIViewSet`, the router, URLs, the v3 UI Component Framework, templates, navigation, tables, forms, filters |
| `rest-api.md` | serializers, viewsets, API versioning, filter extensions, OpenAPI |
| `jobs-and-integrations.md` | Jobs, job hooks and buttons, secrets providers, custom validators, git datasources, Jinja2 filters, events, metrics |
| `testing.md` | `nautobot.apps.testing` case classes, factories, the `invoke` task workflow, CI |
| `security.md` | secrets handling, permissions, sensitive job variables, raw SQL, template escaping, dependency pinning |
| `versioning-migration.md` | v2 to v3 changes, deprecations, version pinning in `NautobotAppConfig` |

Start every file with this header block:

```markdown
---
nautobot_version: v3.2.3
generated: 2026-08-17
sources:
  - https://docs.nautobot.com/projects/core/en/stable/development/apps/api/models/
  - https://raw.githubusercontent.com/nautobot/nautobot/develop/nautobot/apps/models.py
---
```

Use the real version and date from Stage 1. List only the sources that fed that file.

### How to write the body

Write checkable rules, not documentation prose. A reviewer must be able to hold a rule against a diff
and decide yes or no.

- Good: "Import `Device` from `nautobot.apps.models`. Never import from `nautobot.dcim.models`."
- Bad: "Nautobot provides a public API for apps to use."

Further rules:

- Give a short code example for each pattern. Take it from the docs or from the `examples/` directory
  of the nautobot repository. Do not invent examples.
- Mark any behavior that differs between major versions with a line that starts `**v2 vs v3:**`.
- Put the source URL next to each non-obvious rule, so a reviewer can check the claim.
- Never write a rule that no fetched source supports. If a topic returned no usable source, leave the
  section empty and record the gap in `INDEX.md`.
- Keep each file under about 400 lines. An agent loads several of these at once.

## Stage 5 — Report

Print:

1. The Nautobot version the references describe, and its release date.
2. The output directory, and each file with its line count.
3. Every source URL that failed, with the reason.
4. Any section left empty for lack of a source.
5. Any source added this run that `sources.md` does not list, so the user can fold it in.
