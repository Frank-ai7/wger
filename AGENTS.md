# AGENTS.md

General setup, architecture, and commands are documented in `CLAUDE.md` (Python via `uv`,
JS via Yarn 4 / corepack, Django apps under `wger/`). Read that first.

## Cursor Cloud specific instructions

The environment snapshot already has `uv`, Node/Yarn 4, and the required system libraries
installed; the startup update script runs `uv sync --dev`, `yarn install`, and
`yarn build:css:sass`. Notes below are the non-obvious gotchas discovered during setup.

### Services
This repo is a single Django app (the "wger" workout/nutrition tracker) serving both a
server-rendered UI and a DRF API at `/api/v2/`. There is only one service to run:

- Dev server: `uv run python manage.py runserver` (defaults to SQLite). See `CLAUDE.md` for
  lint/test commands. Redis, Celery, MongoDB/OpenFoodFacts, S3, SMTP are all optional and off
  by default.

### Gotchas
- `settings.py` is generated at the **repo root** (`/workspace/settings.py`), not under `wger/`.
  It is gitignored and persists in the VM snapshot. Regenerate with `uv run wger create-settings`
  only if it is missing.
- The dev database is SQLite at the repo root (`database.sqlite`), gitignored and persisted in
  the snapshot. It already has migrations + fixtures applied and an `admin` / `adminadmin`
  superuser. The update script does **not** run migrations/fixtures; if new migrations land,
  run `uv run wger migrate-db` (and `uv run wger load-fixtures` for new reference data) manually.
- System library `libpq5` is required even though dev/test use SQLite: migration
  `wger/exercises/migrations/0029_full_text_search.py` imports `django.contrib.postgres`
  at module load, which imports `psycopg` (v3) and fails without `libpq`. It is preinstalled
  in the snapshot.
- The styled UI depends on `wger/core/static/yarn/bootstrap-compiled.css`, which is compiled
  from `wger/core/static/scss/main.scss` by `yarn build:css:sass` (uses the `sassc` binary,
  symlinked to `sass`). Crucially, `yarn install`'s `postinstall` wipes and recreates
  `wger/core/static/yarn/`, deleting the compiled CSS — so `build:css:sass` must run *after*
  every `yarn install` (the update script already does this in order). Without it the nav/theme
  renders as an unstyled bulleted list.
- Tests use SQLite in-memory and need no external services: `uv run python manage.py test wger`.
  Linting (`uv run ruff check wger/`) reports pre-existing findings; CI auto-formats with
  `ruff format` + `isort` rather than gating on them.
