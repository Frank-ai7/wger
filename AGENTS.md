# AGENTS.md

## Cursor Cloud specific instructions

wger is a Django 5.2 monolith (Python ≥3.10, managed with `uv`) that serves a
server-rendered web UI plus a DRF REST API at `/api/v2/`. JS/CSS assets are
managed with Yarn 4 (via Corepack). Standard dev commands live in `CLAUDE.md`
(setup, runserver, lint, tests); prefer those rather than duplicating them.

The update script already refreshes dependencies on startup (`uv sync --dev`,
Corepack/Yarn install, `wger create-settings`). The notes below cover only the
non-obvious caveats discovered during environment setup.

### Caveats

- **`libpq` is a hard requirement even on SQLite.** The default dev/test DB is
  SQLite, but migration `wger/exercises/migrations/0029_full_text_search.py`
  imports `django.contrib.postgres.operations`, which loads `psycopg` and needs
  the system `libpq` library. It is installed via apt (`libpq5 libpq-dev`) and
  persists in the VM snapshot — no Postgres server is required. If you ever hit
  `libpq library not found` / `No module named 'psycopg2'`, reinstall libpq.
- **Yarn must run through Corepack.** The global `yarn` is 1.x; the project pins
  `yarn@4.9.2`. Run `corepack enable` first, then install with
  `COREPACK_ENABLE_STRICT=0 YARN_IGNORE_PATH=1 yarn install`. A bare `yarn
  install` fails with a packageManager mismatch error. Running `yarn install`
  may rewrite `.yarnrc.yml`/`yarn.lock` into the v8 lockfile format; revert
  those (`git checkout .yarnrc.yml yarn.lock`) before committing — they are
  environment artifacts, not intended changes.
- **`uv` lives in `~/.local/bin`** and is symlinked into `/usr/local/bin` so it
  is on PATH for all shells. `~/.bashrc` also adds `~/.local/bin` to PATH.
- **`settings.py` is generated and gitignored.** It is created at the repo root
  (not `wger/settings.py`) by `uv run wger create-settings` and defaults to a
  SQLite file `database.sqlite`. Both the settings file and the SQLite DB
  persist in the snapshot; migrations/fixtures do not need to re-run each start.
- **Required setup steps after a fresh DB:** `uv run wger migrate-db` then
  `uv run wger load-fixtures` (base languages/licenses/units/gym config). These
  are one-time per database, so they are intentionally NOT in the update script.
- **Run the dev server with** `uv run python manage.py runserver 0.0.0.0:8000`.
  In DEBUG, email uses the console backend, cache is in-process LocMemCache, and
  Celery is disabled — no Redis/Postgres/SMTP/Celery services are needed for a
  working dev instance or the test suite.
- **Tests** use in-memory SQLite automatically; run with
  `uv run python manage.py test wger`. `ruff check wger/` currently reports
  pre-existing lint findings in the repo — those are not introduced by setup.
