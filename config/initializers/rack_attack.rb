class Rack::Attack
  # Limitar peticiones a todas las rutas a 100 por minuto por IP (prevención DDoS general)
  throttle('req/ip', limit: 100, period: 1.minute) do |req|
    req.ip
  end

  # Limitar intentos de login a 5 por minuto por IP (prevención de Brute Force / Credential Stuffing)
  throttle('logins/ip', limit: 5, period: 1.minute) do |req|
    if req.path == '/session' && req.post?
      req.ip
    end
  end

  # Limitar intentos de registro a 3 por hora por IP (prevención de creación masiva de bots)
  throttle('registers/ip', limit: 3, period: 1.hour) do |req|
    if req.path == '/register' && req.post?
      req.ip
    end
  end

  # Formato de respuesta para bloqueos (Too Many Requests)
  self.throttled_response = lambda do |env|
    [ 429,  # status
      { 'Content-Type' => 'application/json' },   # headers
      [{ error: "Has excedido el límite de peticiones. Intenta más tarde." }.to_json] # body
    ]
  end
end
