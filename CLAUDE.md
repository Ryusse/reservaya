# CLAUDE.md

Project context for Claude Code. Keep it short and up to date. **This file is always written in English.**

## What it is

**ReservaYa** — web app for booking physical spaces.
Backend **Rails 8.1** (REST API + JWT) · Frontend **React + TypeScript + Vite** (decoupled SPA) · **PostgreSQL** (in Docker).

Architecture: REST API and frontend as independent layers (RNF07). React consumes the API with `Authorization: Bearer <token>`.

## Running it

```bash
docker compose up -d          # PostgreSQL only (localhost:5432, user/password, reservaya_development)
bundle install && pnpm install
bin/rails db:prepare          # create DB + migrate
bin/rails runner "User.create!(name:'Admin', email:'admin@test.com', password:'secret123', role:1)"

pnpm dev                      # Rails + Vite together (foreman) -> Rails :3100, Vite :3036
# or separately:
pnpm backend                  # bin/rails server -> :3000
pnpm frontend                 # bin/vite dev -> :3036
```

macOS prerequisite: `brew install libpq` + `bundle config build.pg --with-pg-config="$(brew --prefix libpq)/bin/pg_config"`.

Everything runs on the host machine, not in Docker. Docker only runs PostgreSQL.

## Backend

- `app/controllers/application_controller.rb` — `ActionController::Base`. Serves the SPA shell (`PagesController#show` -> `app/views/pages/show.html.erb`).
- `app/controllers/api_controller.rb` — `ActionController::API`, JWT auth (`require_login`, `require_admin`, `current_user`). **Every API controller inherits from here.**
- `app/services/json_web_token.rb` — token encode/decode.
- API views: `app/views/**/*.json.jbuilder`.
- API docs generated from annotations: **`/apipie`** (`apipie-rails` gem, `config/initializers/apipie.rb`, `validate=false`). When touching an endpoint, update its `api ... / param ...` block.
- `config.api_only = false` (serves the API plus the HTML shell).
- Routes: API resources first, then `root "pages#show"` and an HTML catch-all `get "*path"` so client-side deep links serve the SPA.

## Frontend (`app/javascript/`)

Layered, dependencies point inward — `routes -> pages -> hooks -> services -> adapters -> lib/http -> API`:

| Folder | Holds |
|---|---|
| `models/` | domain types (User, Session, Space, Reservation) |
| `adapters/` | map raw jbuilder responses <-> models (dates, enums, snake -> camel) |
| `lib/` | `http` (axios + Bearer interceptor, 401/403 handling), config |
| `services/` | business logic + API calls |
| `hooks/` | `useAuth`, `useSpaces`, … |
| `stores/` | global state with **Zustand** (session: user, token, role) |
| `components/ui/` | **Chakra UI** snippets (`provider`, `color-mode`, `toaster`, `tooltip`). Feature components: `components/<module>/` |
| `pages/` | route containers |
| `routes/` | **TanStack Router** tree (file-based) + role guards |

Router: **TanStack Router**, file-based (`routes/`, generated `routeTree.gen.ts`). State: **Zustand**.
UI: **Chakra UI v3** — use its primitives directly (`Button`, `Stack`, `Dialog.*`, …) with style props / recipes. No CSS Modules, no `cn`/`styled` helpers.
Composition: `entrypoints/application.tsx` (wraps `<Provider>`) -> `App.tsx` -> `router.tsx`.

## Tests & lint

```bash
bin/rails test        # backend (Minitest)
pnpm check            # frontend types (tsc)
pnpm lint             # Biome (lint + format check + import sort) — NOT ESLint/Prettier
pnpm lint:fix         # Biome autofix
pnpm test             # frontend unit tests (Vitest, jsdom) — *.test.ts(x) next to the source
```

Lint/format is **Biome** (`biome.json`). `components/ui/` (Chakra snippets) and `routeTree.gen.ts` are excluded.

## Git workflow

Full details in `docs/gitflow.md`. Summary:

1. Branch **from the issue**: `gh issue develop <N> --base dev --name feature/<ID>-<slug>`
2. Locally: `git fetch origin && git switch feature/<ID>-<slug>`
3. Develop.
4. **Commits = Conventional Commits**: `<type>(<scope>): <desc>` — types `feat|fix|refactor|test|docs|chore|ci|build`, scope `backend`/`frontend`/module (`spaces`, `auth`, `http`, …). Reference the issue with `Refs #<N>` in the footer.
5. `git push -u origin <branch>` -> open the PR -> review -> squash merge.

**PR — always**:
- **Full description**: what it does, why, how to test, and `Closes #<N>`. Use `.github/pull_request_template.md` (DoD checklist).
- **Assigned to `Ryusse`** (`--assignee Ryusse`).
- **Labels** as applicable: `type:*`, `epic:*`, `area:*`, `sprint:*`.
- Example: `gh pr create --base dev --assignee Ryusse --label "type:tarea,area:frontend,sprint:1" --title "..." --body-file <file>`

**Never** add `Co-authored-by`, "Generated with", or any tool trailer/attribution — not in commits, not in the PR body.

## Planning

- Source requirements: `docs/prd/` (APF1 is authoritative).
- `docs/backlog.md` — Product Backlog HU01–HU10.
- `docs/sprint-1.md` — current sprint scope and tasks.
- `docs/frontend-architecture.md` — frontend layer details.
- GitHub Project: https://github.com/users/Ryusse/projects/10 (`Iteración` field = sprints; `sprint:N` label).

## Rules for Claude

- **No comments in code** (any language). Code is explained by clear names. Only exceptions: functional directives (`/// <reference ...>`, linter/TS pragmas that change behavior).
- When **done implementing**, always ask before committing. Never commit without explicit confirmation.
- Commits in Conventional Commits, with scope, **no `Co-authored-by` or trailers**.
- Do not start an issue without first: branch from the issue -> `git fetch` -> `git switch` (see `docs/gitflow.md`).
- All `rails`/`bundle`/`pnpm`/`vite` execution is on the host, not in Docker (Docker only runs PostgreSQL).
- When adding/changing an endpoint: route + controller (`< ApiController`) + jbuilder + apipie annotation + request spec.
- Respect the frontend dependency direction; `components/ui/` never calls `services`.
- **One folder per page / feature component**: `index.tsx` in its own folder, kebab-case name, PascalCase export.
  - Pages: `pages/<module>/<page>/` (a *module* = feature area: `auth`, `spaces`, `reservations`, …); top-level pages without a module go in `pages/<page>/`.
  - Module-specific components: `components/<module>/<name>/`.
  - `components/ui/` holds Chakra snippets (flat `.tsx` files, as the Chakra CLI generates them).
  - Route files in `routes/` only define the route and import the page component from `pages/`.
- **No barrel / `index.ts` re-export files.** Import directly.
- **UI = Chakra UI v3.** Style with Chakra props/recipes, not CSS Modules. Add Chakra snippets with `pnpm dlx @chakra-ui/cli snippet add <name> --tsx --outdir app/javascript/components/ui`.
- This file (`CLAUDE.md`) is always written in English.
