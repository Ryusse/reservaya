# Flujo de trabajo (Git)

## Ramas

| Rama | Uso |
|------|-----|
| `main` | Entregables (APF1–APF4). Solo recibe merge de `dev` en cada hito. |
| `dev` | Integración del sprint activo. |
| `feature/<ID>-<slug>` | Una por issue de desarrollo (`feature/HU01-registro-espacios`). |
| `bugfix/<slug>` | Corrección de defectos hallados en pruebas. |

## Por cada issue

1. **Crear la rama desde el issue** (queda enlazada → el merge del PR cierra el issue):
   ```bash
   gh issue develop <N> --base dev --name feature/<ID>-<slug>
   ```
   (o en la web: issue → *Development* → *Create a branch* → base `dev`)

2. **Traerla y cambiarse en local**:
   ```bash
   git fetch origin
   git switch feature/<ID>-<slug>
   ```

3. Desarrollar la issue.

4. **Commits**: Conventional Commits (ver abajo).

5. **Push y PR**:
   ```bash
   git push -u origin feature/<ID>-<slug>
   gh pr create --base dev --fill
   ```
   El PR usa `.github/pull_request_template.md` (checklist de Definition of Done) y lleva `Closes #<N>`.

6. Review de otro integrante → **merge (squash)** → la tarjeta pasa a *Done*.

## Commits — Conventional Commits + commitlint

```
<tipo>(<scope>): <descripción imperativa, minúscula, sin punto final>
```

- **tipos**: `feat` · `fix` · `refactor` · `test` · `docs` · `chore` · `ci` · `build` · `perf` · `style`
- **scope**: el módulo o capa afectada
  - `backend`, `frontend`
  - o un módulo concreto: `spaces`, `reservations`, `auth`, `users`, `http`, `router`, `db`, …
- descripción ≤ 72 caracteres
- cuerpo opcional: qué y por qué
- referencia al issue en el pie con `Refs #<N>` (el `Closes #<N>` va en el PR, no en cada commit)
- **sin `Co-authored-by` ni trailers de herramientas**

Ejemplos:
```
feat(spaces): validar capacidad > 0 al registrar espacio
fix(backend): responder 404 en espacio inexistente
test(reservations): cubrir solapamiento de horarios
chore(frontend): configurar base ui + css modules
docs: guia de gitflow
```

`commitlint` se valida en un hook `commit-msg` (`commitlint.config.js`) y en CI (HT-03 #37).
