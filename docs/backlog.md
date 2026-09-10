# Product Backlog — ReservaYa

Fuente: `docs/prd/` (APF1 §4.3 y §5.2). Estimación en puntos de historia (Fibonacci).

| ID | Historia | Épica | Pts | Sprint | RF | RNF | Estado |
|----|----------|-------|-----|--------|----|----|--------|
| **HT-01** | Autenticación y control de acceso *(habilitador técnico)* | Usuarios | — | 1 | — | RNF04, RNF07 | No iniciado |
| **HU01** | Registro de espacios | Gestión de espacios | 3 | 1 | RF01 | RNF03 | No iniciado |
| **HU02** | Modificación de espacio (editar / dar de baja) | Gestión de espacios | 3 | 1 | RF02 | RNF03 | No iniciado |
| **HU03** | Registro de nuevo usuario (auto-registro) | Usuarios | 3 | 1 | RF07 | RNF04 | No iniciado |
| **HU04** | Consulta de disponibilidad | Reservas | 5 | 2 | RF03 | RNF02, RNF03 | No iniciado |
| **HU05** | Creación de reserva | Reservas | 5 | 2 | RF04 | RNF05, RNF06 | No iniciado |
| **HU06** | Cancelación de reservas | Reservas | 3 | 3 | RF05 | RNF05 | No iniciado |
| **HU07** | Modificación de reservas | Reservas | 5 | 3 | RF06 | RNF05 | No iniciado |
| **HU08** | Dashboard de ocupación | Monitoreo | 5 | 3 | RF08 | RNF03 | No iniciado |
| **HU09** | Reportes de reservas y ocupación | Reportes | 5 | 4 | RF09 | — | No iniciado |
| **HU10** | Notificaciones de reserva | Notificaciones | 5 | 4 | RF10 | — | No iniciado |

Total: **42 puntos** en 4 sprints.

## Requisitos no funcionales (aplican a casi todo)

| Código | Descripción | Dónde impacta |
|--------|-------------|---------------|
| RNF01 | Disponibilidad ≥ 99% del horario laboral | despliegue |
| RNF02 | Consulta de disponibilidad < 2 s | HU04 (índices en `reservations`) |
| RNF03 | Interfaz responsive (sin app nativa) | todo el frontend (Tailwind) |
| RNF04 | Autenticación obligatoria + contraseñas con hash | HT-01, HU03 (`has_secure_password`) |
| RNF05 | Validación de disponibilidad atómica (anti doble reserva) | HU05, HU06, HU07 (índice único + transacción) |
| RNF06 | Flujo de reserva ≤ 3 pasos | HU05 (UX) |
| RNF07 | API REST y frontend en capas independientes | arquitectura (ver `docs/sprint-1.md`) |
