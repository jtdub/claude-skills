# Output file outline

The `nautobot-references` skill reads this file at Stage 4. Use these headings verbatim in the
generated files. A fixed structure keeps successive runs diffable, so the user can see what changed
in Nautobot rather than what changed in the wording.

If a source yields nothing for a section, keep the heading and write `No source found this run.`
Then record the gap in `INDEX.md`.

---

## INDEX.md

```
# Nautobot References

## Version covered
## File map
## Sources
## Fetch failures
## Sources added this run
## Gaps
```

The version section states the Nautobot tag, its release date, and the generation date. The file map
is a table of file name, subject, and line count. Under Gaps, name each empty section and why.

---

## app-structure.md

```
## Directory layout
## NautobotAppConfig
## Package metadata and entry point
## Configuration and PLUGINS_CONFIG
## Documentation and changelog
## Development environment
```

---

## public-api.md

```
## The import rule
## Module map
## Per-module exports
## Common mistakes
```

The import rule section states plainly that apps import from `nautobot.apps.*` only. The module map
is a table of module, subject, and typical use. Per-module exports lists the `__all__` contents of
each module. Common mistakes pairs a wrong import with its correct replacement.

---

## models.md

```
## Base classes
## Choosing a base class
## Required model attributes
## Natural keys
## Migrations
## Querysets and managers
## Model features
## GraphQL
## Global search
## Django admin
## Model checklist
```

---

## views-and-ui.md

```
## NautobotUIViewSet
## The router and URLs
## UI Component Framework
## Templates
## Navigation
## Tables
## Forms
## Filters and FilterSets
## Object view extensions
## Home page and banners
```

Every section that changed between v2 and v3 carries a `**v2 vs v3:**` line.

---

## rest-api.md

```
## Serializers
## Viewsets
## API URLs
## API versioning
## Filtering
## OpenAPI schema
## Testing the API
```

---

## jobs-and-integrations.md

```
## Job structure
## Job registration
## Job variables and inputs
## Job logging
## Job hooks and job buttons
## Custom validators
## Secrets providers
## Git repository datasources
## Jinja2 filters
## Events
## Metrics
```

---

## testing.md

```
## Test case classes
## View test cases
## API test cases
## Filter test cases
## Factories and test data
## Running tests
## CI
```

---

## security.md

```
## Secrets
## Permissions and object permissions
## Sensitive job variables
## Database access
## Template and table rendering
## External requests
## Dependencies
## Disclosure policy
```

Each section lists the concrete failure to look for, then the correct pattern.

---

## versioning-migration.md

```
## Supported versions
## Version pinning in NautobotAppConfig
## v2 to v3 changes
## Deprecations
## Removed APIs
## Migration checklist
```
