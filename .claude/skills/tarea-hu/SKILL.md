---
name: tarea-hu
description: Flujo completo para implementar una tarea de una Historia de Usuario en ReservaYa, siguiendo GitFlow (rama desde el issue, código, tests, apipie, PR contra dev).
---

# Implementar una tarea de HU

Usar cuando haya que desarrollar un issue `[BE]`/`[FE]` hijo de una historia (HU) o habilitador (HT).

## Pasos

1. **Rama desde el issue** (nunca empezar sin esto):
   ```bash
   gh issue develop <N> --base dev --name feature/<ID>-<slug>
   git fetch origin && git switch feature/<ID>-<slug>
   ```
   `<ID>` = `HU01`, `HT02`, … · `<slug>` = kebab-case corto. Mover el issue a **In Progress** en el Project.

2. **Implementar** respetando `CLAUDE.md`:
   - Sin comentarios en código (solo pragmas funcionales).
   - Backend: controlador `< ApiController`, jbuilder en `app/views/**/*.json.jbuilder`.
   - Frontend: dirección de dependencias `routes -> pages -> hooks -> services -> adapters -> lib -> API`; una carpeta por componente con `index.tsx` kebab-case; UI con Chakra v3; sin barrels.

3. **Endpoint tocado** (si aplica): ruta + controlador + jbuilder + **anotación apipie** (`api`/`param`/`error`) + request spec. Ver skill `nuevo-endpoint`.

4. **Tests**:
   ```bash
   bin/rails test        # backend
   pnpm check            # tipos
   pnpm lint             # Biome
   pnpm test             # Vitest
   ```
   Todo en verde antes de continuar.

5. **Commit** — Conventional Commits con scope, footer `Refs #<N>`. Sin `Co-authored-by` ni trailers. **Preguntar antes de commitear.**

6. **PR contra `dev`**:
   ```bash
   gh pr create --base dev --assignee Ryusse \
     --label "type:tarea,area:<backend|frontend|infra>,sprint:<n>" \
     --title "<HU/HT> · <desc>" --body-file <archivo>
   ```
   Cuerpo con: qué hace, cómo probar, `Closes #<N>`, checklist DoD (`.github/pull_request_template.md`). Mover el issue a **In Review**.

7. **Merge squash a `dev`**. Como `dev` no es la rama por defecto, `Closes #<N>` no cierra el issue: **cerrarlo a mano** y moverlo a **Done**. Borrar la rama.

## Referencias

- `docs/gitflow.md` · `docs/sprint-1.md` · `docs/backlog.md`
- Tablero: https://github.com/users/Ryusse/projects/10
