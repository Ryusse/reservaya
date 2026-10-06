# Orígenes permitidos: localhost para desarrollo + FRONTEND_URL (admite varios separados por coma).
# Se normalizan espacios y barras finales porque el navegador envía el Origin sin "/" final y
# Rack::Cors compara por igualdad exacta; si no, el preflight responde sin Access-Control-Allow-Origin.
DEFAULT_FRONTEND_URL = "https://reservaya.up.railway.app".freeze

cors_origins = [
  "http://localhost:3000",
  "http://127.0.0.1:3000",
  *ENV.fetch("FRONTEND_URL", DEFAULT_FRONTEND_URL).split(",")
].map { |origin| origin.strip.chomp("/") }.reject(&:empty?).uniq

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*cors_origins)

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end
end
