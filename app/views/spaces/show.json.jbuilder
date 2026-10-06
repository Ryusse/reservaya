json.partial! "spaces/space", space: @space
json.date @date
json.available @space.active? && @space.availability_blocks(@date).any? { |b| b[:status] != "full" }
json.availability @space.availability_blocks(@date) do |block|
  json.start_time block[:start_time]
  json.end_time block[:end_time]
  json.status block[:status]
  json.seats_available block[:seats_available]
end
json.reservations @reservations do |reservation|
  json.id reservation.id
  json.user_id reservation.user_id
  json.date reservation.date
  json.start_time reservation.start_time&.strftime("%H:%M")
  json.end_time reservation.end_time&.strftime("%H:%M")
  json.status reservation.status
  json.seats_reserved reservation.seats_reserved
end
