# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Setup

```bash
uv sync --dev                  # install Python dependencies
COREPACK_ENABLE_STRICT=0 YARN_IGNORE_PATH=1 yarn install  # install JS dependencies
uv run wger create-settings    # generate settings.py (first time only)
uv run wger migrate-db         # run database migrations
uv run wger load-fixtures      # load initial data (languages, licenses, units, etc.)
```

### Running the app

```bash
uv run python manage.py runserver
```

### Linting

```bash
uv run ruff check wger/        # lint
uv run ruff check --fix wger/  # lint and auto-fix
uv run isort wger/             # sort imports
```

### Tests

```bash
uv run python manage.py test wger                                    # full suite
uv run python manage.py test wger.core.tests.test_user               # single module
uv run python manage.py test wger.core.tests.test_user.UserTestCase  # single class
```

## Architecture

wger is a Django application organised as a collection of standalone Django apps under `wger/`:

| App | Responsibility |
| --- | --- |
| `core` | Users, profiles, authentication, languages, licenses |
| `manager` | Workout routines, days, slots, slot entries, workout logs, sessions |
| `exercises` | Exercise database, translations, images, videos, categories, muscles |
| `nutrition` | Nutrition plans, meals, ingredients, diary |
| `weight` | Body weight entries |
| `measurements` | Custom measurement categories and entries |
| `gallery` | Progress photo uploads |
| `gym` | Multi-tenant gym management, trainer/member relationships |
| `config` | Per-gym configuration |
| `utils` | Shared base classes, cache helpers, generic views |

### REST API

All data is exposed through a DRF REST API at `/api/v2/`. The router registration lives in
`wger/urls.py`. Every app follows the same pattern:

```text
wger/<app>/api/
  views.py       — ViewSets
  serializers.py — Serializers
  permissions.py — Permission classes
  filtersets.py  — django-filter FilterSets
```

### Ownership / access control

User data is scoped strictly per user. The base viewset `WgerOwnerObjectModelViewSet`
(in `wger/utils/viewsets.py`) enforces this on writes by walking `get_owner_objects()` on the
viewset to verify that referenced parent objects belong to the requesting user.

Each model in the ownership chain exposes `get_owner_object()`, which chains up to the model
that holds the `user` FK. For example: `SlotEntry -> Slot -> Day -> Routine` (which has `user`).

API views filter list queries to `request.user` directly in `get_queryset()`.

### Settings

Global, environment-agnostic settings live in `wger/settings_global.py`. A local `settings.py`
(gitignored) is generated via `wger create-settings` and imports from `settings_global`.
`manage.py` locates and loads it automatically.

App-level feature flags live in `settings_global.WGER_SETTINGS`
(e.g. `USE_CELERY`, `ALLOW_REGISTRATION`, `WGER_INSTANCE`).

### Caching

Cache keys are centralised in `wger/utils/cache.py` (`CacheKeyMapper`). Exercise API responses
and routine data are cached with TTLs defined in `WGER_SETTINGS`. Cache invalidation helpers
(`reset_exercise_api_cache`, `reset_workout_log`, etc.) live in the same file.

### Static assets / JS

JS dependencies are managed with Yarn and copied into `wger/core/static/yarn/` via the
`postinstall` script. This directory is gitignored; it is rebuilt during the session start hook.

### Data model — manager app

The workout routine data model is hierarchical:

```text
Routine  (user, name)
  └── Day  (routine, name, order)
        └── Slot  (day, order)
              └── SlotEntry  (slot, exercise)
                    └── *Config  (slot_entry, iteration, value)
```

`*Config` models (`WeightConfig`, `RepetitionsConfig`, `SetsConfig`, etc.) each carry an
`iteration` field that supports per-week progression rules. `MaxWeightConfig` /
`MaxRepetitionsConfig` etc. are sibling models that cap the progression.

### Fixtures

`wger/load-fixtures` loads the base reference data required for the app to function (languages,
groups, users, licenses, weight/repetition units, gym config). Test fixtures under each app's
`fixtures/` directory are prefixed with `test-`.

### Testing conventions

- Base test case: `wger.core.tests.base_testcase.BaseTestCase`
- Base API test case: `wger.core.tests.api_base_test.ApiBaseTestCase`
- `ApiBaseTestCase` declares `resource`, `pk`, `data`, `private_resource`, `user_access`, and
  `user_fail` and auto-generates CRUD tests covering authentication and ownership boundaries.
- Tests use SQLite in-memory by default (configured in the generated `settings.py`).
