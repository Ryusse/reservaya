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

## Tests dentro del contenedor de desarrollo

`Dockerfile-dev` ya NO fija `RAILS_ENV` a nivel de imagen (antes tenía `ENV RAILS_ENV
development`, lo que hacía que `bundle exec rspec` corriera por error contra el entorno
`development` y fallara con `403 Blocked hosts` en vez de ejecutar los tests). Ahora:

```bash
docker exec -it reservaya-backend-api-1 bundle exec rspec   # corre en test, sin flags extra
docker exec -it reservaya-backend-api-1 bin/rails server    # sigue arrancando en development
```

Si en algún momento se vuelve a fijar `RAILS_ENV` a nivel de imagen o de shell, forzar
explícitamente `-e RAILS_ENV=test` en los comandos de test como red de seguridad.
