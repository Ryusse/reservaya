Apipie.configure do |config|
  config.app_name                = "Reservaya"
  config.app_info                = "API de reservas de espacios. Auth por JWT: POST /session devuelve un token; el resto de rutas requieren el header Authorization: Bearer <token>."
  config.api_base_url            = ""
  config.doc_base_url            = "/apipie"
  config.default_version         = "1.0"
  # Solo escanea los controllers de la API.
  config.api_controllers_matcher = Rails.root.join("app", "controllers", "{sessions,users,spaces,reservations}_controller.rb").to_s
  # Doc-only: no valida ni rechaza requests.
  config.validate                = false
  config.translate               = false
end
