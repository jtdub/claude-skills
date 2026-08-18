# Source map

The `nautobot-references` skill reads this file at Stage 2. It lists what to select from the live
documentation sitemap and what to pull from GitHub.

These patterns are a filter, not a fixed page list. The skill always reads the live sitemap. If the
sitemap grows a section that is clearly relevant to app development, include it and record the
addition in the generated `INDEX.md`.

## Documentation sitemap

Sitemap URL: `https://docs.nautobot.com/projects/core/en/stable/sitemap.xml`

Base prefix stripped from each entry below: `https://docs.nautobot.com/projects/core/en/stable/`

The sitemap is the discovery mechanism. It is not the fetch mechanism. Fetch each page as raw
markdown from the tagged release, as described in Stage 3 of `SKILL.md`:

```
https://raw.githubusercontent.com/nautobot/nautobot/<tag>/nautobot/docs/<path>.md
https://raw.githubusercontent.com/nautobot/nautobot/<tag>/nautobot/docs/<path>/index.md
```

| Pattern | Approx. pages | Feeds |
|---|---|---|
| `development/apps/**` | 60 | every output file |
| `development/core/**` | 23 | `models.md`, `views-and-ui.md`, `testing.md`, `app-structure.md` |
| `development/jobs/**` | 10 | `jobs-and-integrations.md` |
| `code-reference/nautobot/apps/**` | 26 | skip — these are generated API docs; read each module's `__all__` from source instead, which is exact and far cheaper |
| `user-guide/platform-functionality/**` | 48 | `jobs-and-integrations.md`, `security.md`, `models.md` |
| `release-notes/version-3.*` | 3 | `versioning-migration.md` |
| `release-notes/version-2.*` | 5 | `versioning-migration.md` (v2 differences only) |
| `apps/**` | 2 | `app-structure.md` |
| `overview/design_philosophy/` | 1 | `INDEX.md` framing |

### High-value pages

Fetch these first. They carry the densest rules.

- `development/core/best-practices/`
- `development/core/style-guide/`
- `development/core/model-checklist/`
- `development/core/model-features/`
- `development/core/natural-keys/`
- `development/core/ui-best-practices/`
- `development/core/ui-component-framework/`
- `development/core/testing/`
- `development/apps/api/setup/`
- `development/apps/api/nautobot-app-config/`
- `development/apps/api/models/`
- `development/apps/api/views/nautobotuiviewset/`
- `development/apps/api/views/rest-api/`
- `development/apps/api/testing/`
- `development/apps/migration/ui-component-framework/best-practices/`
- `development/apps/migration/from-v2/overview/`
- `development/apps/migration/from-v2/migrating-v2-to-v3/`

### Path notes

Verified against the v3.2.3 sitemap:

- The Prometheus page is `development/apps/api/prometheus/`, **not** under `platform-features/`.
  OpenTelemetry *is* under `platform-features/`.
- `development/core/**` is written for core developers but most of it applies directly to apps.
  `best-practices`, `style-guide`, `model-checklist`, `model-features`, `natural-keys`,
  `ui-component-framework`, `ui-best-practices`, and `testing` are the highest value pages in the
  whole set.

### Pages to skip

These are about running or releasing Nautobot itself, not about writing an app.

- `development/core/docker-compose-advanced-use-cases/`
- `development/core/docs-media-standards/`
- `development/core/release-checklist/`
- `development/core/running-jobs-locally-kubernetes/`
- `user-guide/administration/**`
- `user-guide/core-data-model/**` unless a specific model is under review
- `user-guide/feature-guides/**`

## GitHub

Repository: `https://github.com/nautobot/nautobot` (branch `develop`)

| Source | Use |
|---|---|
| `https://api.github.com/repos/nautobot/nautobot/releases/latest` | the current stable version tag and release date |
| `https://api.github.com/repos/nautobot/nautobot/contents/nautobot/apps?ref=develop` | the live list of public API modules |
| `https://raw.githubusercontent.com/nautobot/nautobot/develop/nautobot/apps/<module>.py` | the `__all__` tuple of each module, which is the authoritative export list |
| `https://raw.githubusercontent.com/nautobot/nautobot/develop/CONTRIBUTING.md` | contribution and changelog fragment rules |
| `https://raw.githubusercontent.com/nautobot/nautobot/develop/SECURITY.md` | the supported-version and disclosure policy |
| `https://api.github.com/repos/nautobot/nautobot/contents/examples?ref=develop` | the in-tree example app, for canonical code |
| `https://api.github.com/repos/nautobot/nautobot/contents/changes?ref=develop` | the towncrier fragment naming convention |
| `https://raw.githubusercontent.com/nautobot/nautobot/<tag>/nautobot/docs/<path>.md` | the source markdown behind every documentation page |

Read the `__all__` tuple of every module the contents API returns. Do not assume the module list from
a previous run. As of the last verified check the set was: `admin`, `api`, `change_logging`,
`choices`, `config`, `constants`, `datasources`, `dcim`, `events`, `exceptions`, `factory`, `filters`,
`forms`, `graphql`, `jobs`, `models`, `querysets`, `secrets`, `tables`, `templatetags`, `testing`,
`ui`, `urls`, `utils`, `views`.

### Related repositories

| Repository | Use |
|---|---|
| `https://github.com/nautobot/cookiecutter-nautobot-app` | the canonical app scaffold and directory layout |
| `https://docs.nautobot.com/projects/core/en/stable/apps/nautobot-apps/` | the published app list, useful for finding real-world examples |

## Rate limits

The unauthenticated GitHub API allows 60 requests per hour. Prefer `raw.githubusercontent.com`, which
is not rate limited the same way. If `gh` is authenticated, use `gh api` instead of `curl` on
`api.github.com`.
