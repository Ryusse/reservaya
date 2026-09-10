#!/usr/bin/env bash
# Crea el GitHub Project "ReservaYa" bajo la cuenta Ryusse, lo enlaza al repo,
# crea labels, campos, y los issues de Sprint 1 (HT-01, HU01-HU03 + tareas).
#
# Requisitos (una vez):
#   brew install gh
#   gh auth login
#   gh auth refresh -s project
#
# Uso:  bash scripts/setup_github_project.sh
set -euo pipefail

OWNER="Ryusse"
REPO="Ryusse/reservaya"
PROJECT_TITLE="ReservaYa"

command -v gh >/dev/null || { echo "Falta 'gh' -> brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh no autenticado -> gh auth login"; exit 1; }
gh auth status 2>&1 | grep -q "project" || { echo "Falta scope 'project' -> gh auth refresh -s project"; exit 1; }

echo "==> Labels"
label() { gh label create "$1" --repo "$REPO" --color "$2" --description "$3" --force >/dev/null; }
label "type:historia"    "1D76DB" "Historia de usuario"
label "type:habilitador" "5319E7" "Habilitador tecnico"
label "type:tarea"       "0E8A16" "Tarea de una HU"
label "type:bug"         "D73A4A" "Defecto"
label "epic:espacios"    "BFD4F2" "Epica: gestion de espacios"
label "epic:usuarios"    "BFD4F2" "Epica: usuarios"
label "epic:reservas"    "BFD4F2" "Epica: reservas"
label "area:backend"     "FBCA04" "Backend / API"
label "area:frontend"    "FBCA04" "Frontend / React"
label "area:qa"          "FBCA04" "Pruebas"
label "sprint:1"         "C2E0C6" "Sprint 1"

echo "==> Project"
PNUM=$(gh project list --owner "$OWNER" --format json --jq \
  ".projects[] | select(.title==\"$PROJECT_TITLE\") | .number" | head -1 || true)
if [ -z "${PNUM:-}" ]; then
  PNUM=$(gh project create --owner "$OWNER" --title "$PROJECT_TITLE" --format json --jq '.number')
  echo "   creado #$PNUM"
else
  echo "   ya existe #$PNUM"
fi
gh project link "$PNUM" --owner "$OWNER" --repo "$REPO" >/dev/null || true

echo "==> Campos"
field() { gh project field-create "$PNUM" --owner "$OWNER" --name "$1" --data-type "$2" ${3:+--single-select-options "$3"} >/dev/null 2>&1 || true; }
field "Tipo"   SINGLE_SELECT "historia,habilitador,tarea,bug"
field "Sprint" SINGLE_SELECT "Sprint 1,Sprint 2,Sprint 3,Sprint 4"
field "Area"   SINGLE_SELECT "backend,frontend,qa"
field "Puntos" NUMBER

add_to_project() { gh project item-add "$PNUM" --owner "$OWNER" --url "$1" >/dev/null; }

mkissue() { # titulo  labels  body  -> imprime la URL
  gh issue create --repo "$REPO" --title "$1" --label "$2" --body "$3"
}

echo "==> Issues padre"
HT01=$(mkissue "HT-01 · Autenticación y control de acceso" "type:habilitador,epic:usuarios,sprint:1" \
"Habilitador. HU01/HU02 presuponen un admin autenticado y el RNF04 exige autenticación; no hay HU de login.

**Alcance**
- BE: \`POST /session\` y \`require_login\`/\`require_admin\` ya existen. Añadir \`db/seeds.rb\` (1 admin) y \`rescue_from RecordNotFound\` -> 404 JSON.
- FE: pantalla Login, cliente HTTP con \`Authorization: Bearer\`, guard 401->Login, UI segun rol.

Tareas: ver sub-issues.")
HU01=$(mkissue "HU01 · Registro de espacios" "type:historia,epic:espacios,sprint:1" \
"**Como** administrador de espacios **necesito** registrar un espacio (nombre, capacidad, ubicación, horario) **para** que los usuarios puedan reservarlo.

**Escenarios:** registro exitoso · datos incompletos · capacidad ≤ 0 · horario inconsistente.
**Cubre:** RF01, RNF03. **Puntos:** 3.
**Estado:** \`POST /spaces\` (admin) y validaciones \`capacity > 0\` / \`end_time > start_time\` ya existen.

Tareas: ver sub-issues.")
HU02=$(mkissue "HU02 · Modificación de espacio" "type:historia,epic:espacios,sprint:1" \
"**Como** administrador de espacios **necesito** editar y/o dar de baja un espacio **para** que los usuarios no puedan reservarlo.

**Escenarios:** edición exitosa · dar de baja · espacio inexistente · modificación inválida.
**Cubre:** RF02, RNF03. **Puntos:** 3.
**Estado:** \`PATCH\`/\`DELETE /spaces/:id\` (soft-delete) ya existen; falta el 404.

Tareas: ver sub-issues.")
HU03=$(mkissue "HU03 · Registro de nuevo usuario" "type:historia,epic:usuarios,sprint:1" \
"**Como** usuario no registrado **necesito** registrarme como usuario institucional **para** poder reservar espacios.

**Escenarios:** registro exitoso · datos inválidos · credenciales ya registradas.
**Cubre:** RF07, RNF04 (hash). **Puntos:** 3.
**Estado:** \`User\` con \`has_secure_password\` y email único ya existen; falta endpoint público \`POST /register\`.

Tareas: ver sub-issues.")

for u in "$HT01" "$HU01" "$HU02" "$HU03"; do add_to_project "$u"; done

echo "==> Sub-issues (tareas)"
task() { # padre_url  titulo  labels  body
  local url; url=$(mkissue "$2" "$3" "Padre: $1

$4")
  add_to_project "$url"
  # enlaza como sub-issue (best effort; requiere sub-issues habilitado)
  local pnum sid
  pnum=$(basename "$1"); sid=$(gh issue view "$url" --repo "$REPO" --json id --jq '.id' 2>/dev/null || true)
  [ -n "${sid:-}" ] && gh api -X POST "repos/$REPO/issues/$pnum/sub_issues" -f "sub_issue_id=$sid" >/dev/null 2>&1 || true
}

task "$HT01" "[BE] HT-01 · Seed de admin + 404 consistente" "type:tarea,area:backend,sprint:1" \
"- [ ] \`db/seeds.rb\`: 1 admin + 2-3 espacios de ejemplo
- [ ] \`rescue_from ActiveRecord::RecordNotFound\` en \`ApiController\` -> 404 JSON"
task "$HT01" "[FE] HT-01 · Login + cliente HTTP con token" "type:tarea,area:frontend,sprint:1" \
"- [ ] Pantalla Login (consume \`POST /session\`, guarda JWT)
- [ ] Cliente HTTP con \`Authorization: Bearer\` + guard 401 -> Login
- [ ] Mostrar/ocultar UI de admin segun rol; manejar 403"
task "$HT01" "[QA] HT-01 · Pruebas de acceso" "type:tarea,area:qa,sprint:1" \
"- [ ] Login OK / credenciales inválidas / acceso sin token"

task "$HU01" "[BE] HU01 · Validaciones + specs + apipie" "type:tarea,area:backend,sprint:1" \
"- [ ] Definir si \`start_time\`/\`end_time\` son obligatorios + validación
- [ ] request specs \`POST /spaces\` (4 escenarios)
- [ ] anotación apipie"
task "$HU01" "[FE] HU01 · Form + listado de espacios" "type:tarea,area:frontend,sprint:1" \
"- [ ] Form 'Nuevo espacio' con validación
- [ ] Listado del catálogo (espacios activos)"
task "$HU01" "[QA] HU01 · Pruebas funcionales" "type:tarea,area:qa,sprint:1" \
"- [ ] 4 escenarios (éxito, incompletos, capacidad ≤ 0, horario inconsistente)"

task "$HU02" "[BE] HU02 · 404 + specs + apipie" "type:tarea,area:backend,sprint:1" \
"- [ ] 404 en espacio inexistente
- [ ] request specs \`PATCH\`/\`DELETE /spaces/:id\`
- [ ] apipie"
task "$HU02" "[FE] HU02 · Editar + dar de baja" "type:tarea,area:frontend,sprint:1" \
"- [ ] Editar espacio (form precargado)
- [ ] 'Dar de baja' con confirmación; el espacio sale del listado"
task "$HU02" "[QA] HU02 · Pruebas funcionales" "type:tarea,area:qa,sprint:1" \
"- [ ] 4 escenarios (editar, baja, inexistente, inválido)"

task "$HU03" "[BE] HU03 · POST /register + specs + apipie" "type:tarea,area:backend,sprint:1" \
"- [ ] \`RegistrationsController\` + ruta \`POST /register\` (público, rol \`user\` forzado)
- [ ] Mensaje claro en email duplicado (422)
- [ ] request specs (éxito, inválido, duplicado) + apipie"
task "$HU03" "[FE] HU03 · Pantalla de registro" "type:tarea,area:frontend,sprint:1" \
"- [ ] Form de registro con validación
- [ ] Post-registro: login automático o redirect a Login"
task "$HU03" "[QA] HU03 · Pruebas + hash" "type:tarea,area:qa,sprint:1" \
"- [ ] 3 escenarios + verificar que \`password_digest\` es hash en BD (RNF04)"

echo
echo "Listo. Project: https://github.com/users/$OWNER/projects/$PNUM"
echo "Ajusta en la UI: campo Sprint='Sprint 1', Puntos, y activa las automatizaciones (Item cerrado -> Done, PR -> In Review)."
