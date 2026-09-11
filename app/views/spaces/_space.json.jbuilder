json.id space.id
json.name space.name
json.capacity space.capacity
json.location space.location
json.start_time space.start_time&.strftime("%H:%M")
json.end_time space.end_time&.strftime("%H:%M")
json.status space.status
json.space_type space.space_type