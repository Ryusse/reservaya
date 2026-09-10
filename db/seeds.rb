admin = User.find_or_create_by!(email: "admin@test.com") do |user|
  user.name = "Administrador"
  user.password = "secret123"
  user.role = :admin
end

User.find_or_create_by!(email: "user@test.com") do |user|
  user.name = "Usuario Institucional"
  user.password = "secret123"
  user.role = :user
end

[
  { name: "Sala A", location: "Piso 2", capacity: 10, start_time: "08:00", end_time: "20:00", status: :active },
  { name: "Sala B", location: "Piso 3", capacity: 6, start_time: "09:00", end_time: "18:00", status: :active },
  { name: "Auditorio", location: "Piso 1", capacity: 80, start_time: "08:00", end_time: "22:00", status: :active },
].each do |attrs|
  Space.find_or_create_by!(name: attrs[:name]) { |space| space.assign_attributes(attrs) }
end

Rails.logger.info("Seed listo: #{User.count} usuarios (#{admin.email}), #{Space.count} espacios")
