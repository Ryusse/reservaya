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
| `components/ui/` | wrapped **Base UI** · `components/<feature>/` |
| `pages/` | route containers |
| `routes/` | **TanStack Router** tree (file-based) + role guards |

Router: **TanStack Router**, file-based (`routes/`, generated `routeTree.gen.ts`). State: **Zustand**.
Styling: **CSS Modules** (`*.module.css`); components from **Base UI**. Details in `docs/frontend-architecture.md`.
Composition: `entrypoints/application.tsx` -> `App.tsx` -> `router.tsx`.

## Tests

```bash
bin/rails test        # backend (Minitest)
pnpm check            # frontend tsc
```

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
- This file (`CLAUDE.md`) is always written in English.
