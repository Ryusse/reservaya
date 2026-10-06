---
name: github-projects-workflow
description: >-
  Regla para el manejo de Issues y Proyectos en GitHub (Creación de sub-tareas y dependencias).
trigger: always_on
---

# Flujo de Trabajo en GitHub Projects (Sub-tareas)

Cuando se solicite crear una nueva tarea, issue, o dividir una historia de usuario en backend/frontend:

1. **NO usar solo Tasklists en markdown** si el issue padre ya existe, y NO dejar issues sin conexión.
2. **Crear las tareas hijas desde la jerarquía correcta**: Si se requiere crear una sub-tarea para una Historia de Usuario (HU), asegúrate de conectarla explícitamente como "Sub-issue" para que la UI de GitHub Projects la detecte automáticamente en las vistas jerárquicas (View 6).
3. **Comandos (CLI)**: Como `gh` CLI no soporta nativamente el campo "Parent issue" de los proyectos V2 ni el endpoint de Sub-issues V2 por defecto, para vincular un issue hijo a uno padre se debe editar el cuerpo del issue padre agregando un tasklist markdown (`- [ ] #ID_HIJO`), lo cual GitHub parsea como sub-issues. Alternativamente, puedes pedirle al usuario usar el botón nativo de la UI.
4. **Campos de Proyecto**: Asegúrate de setear los campos customizados del tablero siempre que crees un issue:
   - `Iteración` (Sprint X)
   - `Tipo` (tarea, bug, historia)
   - `Area` (frontend, backend)
   - `Status` (Todo, In Progress, Done)

Este es el estándar de oro para el repositorio `reservaya`.
