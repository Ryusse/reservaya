json.partial! "spaces/space", space: @space
json.date @date
json.reservations @reservations do |r|
  json.id r.id
  json.start_time r.start_time
  json.end_time r.end_time
  json.status r.status
end