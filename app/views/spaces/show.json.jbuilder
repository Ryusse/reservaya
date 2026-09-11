json.partial! "spaces/space", space: @space
json.date @date
json.reservations @reservations do |reservation|
  json.id reservation.id
  json.user_id reservation.user_id
  json.date reservation.date
  json.start_time reservation.start_time&.strftime("%H:%M")
  json.end_time reservation.end_time&.strftime("%H:%M")
  json.status reservation.status
  json.seats_reserved reservation.seats_reserved
end