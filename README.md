# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Datos de ejemplo (seed)

`bin/rails db:seed` crea un administrador y algunos espacios de ejemplo para desarrollo/QA:

- Admin: `admin@reservaya.local` / `password123`
- Espacios: uno privado, uno compartido y uno inactivo, todos con horario 08:00-18:00

Es idempotente — se puede correr varias veces sin duplicar registros.
