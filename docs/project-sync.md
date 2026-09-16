# Project sync (GitHub Project #10 automation)

`.github/workflows/project-sync.yml` mueve automáticamente la card de un issue en
[Project #10 — ReservaYa](https://github.com/users/Ryusse/projects/10) según el estado real
de git/PR. Nunca mueve una card hacia atrás.

## Mapeo de fases

| Trigger | Condición | Status destino |
|---|---|---|
| `push` a una rama (no `dev`/`main`) | el diff contra `dev` agrega/modifica `specs/**/tasks.md` y nada más | `Todo` (specify+plan+tasks listos) |
| `push` a una rama | el diff contra `dev` toca algo fuera de `specs/`, `.specify/`, `docs/` | `In Progress` (implementación arrancó) |
| `pull_request` `opened`/`ready_for_review` | el título o body tiene `Closes #N` / `Refs #N` (mismo repo u `owner/repo#N` cruzado) | `In Review` |
| `pull_request` `closed` con `merged: true` | ídem | `Done` |

El issue se ubica en el `push` vía **linked branches** (`gh issue develop <N> --name <rama>`
lo enlaza automáticamente) — no se parsea el nombre de la rama, porque no todas siguen
`feature/<issue>-<slug>` (algunas usan un código tipo `HT04`).

`Backlog` es el estado inicial y no requiere automatización (se asigna al crear el issue).

## Setup requerido: `PROJECTS_TOKEN`

El `GITHUB_TOKEN` por defecto de Actions no puede escribir en un Project de usuario. Hace falta
un Personal Access Token con scope `project` (y `repo` para leer issues/PRs):

1. https://github.com/settings/tokens → **Generate new token (classic)** → scopes `repo` + `project`.
2. En cada repo (`reservaya` y `reservaya-frontend`): **Settings → Secrets and variables →
   Actions → New repository secret** → nombre `PROJECTS_TOKEN`, valor el token generado.

Sin ese secret el workflow corre pero cada paso de `gh project item-edit` falla con 401/403.

## Por qué no auto-cierra el issue

`dev` no es la rama por defecto, así que un merge a `dev` no cierra el issue aunque el PR diga
`Closes #N` (limitación de GitHub, no de este workflow). El workflow solo mueve la card a `Done`;
cerrar el issue a mano sigue siendo el último paso manual documentado en `docs/gitflow.md`.
