admin = User.find_or_create_by!(email: "admin@reservaya.local") do |user|
  user.name = "Admin"
  user.password = "password123"
  user.role = :admin
end
admin.update!(role: :admin) unless admin.admin?

Space.find_or_create_by!(name: "Sala Privada Demo") do |space|
  space.capacity = 4
  space.location = "Piso 1"
  space.start_time = "08:00"
  space.end_time = "18:00"
  space.status = :active
  space.space_type = :private_space
end

Space.find_or_create_by!(name: "Sala Compartida Demo") do |space|
  space.capacity = 10
  space.location = "Piso 2"
  space.start_time = "08:00"
  space.end_time = "18:00"
  space.status = :active
  space.space_type = :shared_space
end

Space.find_or_create_by!(name: "Sala Inactiva Demo") do |space|
  space.capacity = 6
  space.location = "Piso 3"
  space.start_time = "08:00"
  space.end_time = "18:00"
  space.status = :inactive
  space.space_type = :shared_space
end
