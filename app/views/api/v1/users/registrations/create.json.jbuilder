json.status do
  json.code 201 # 201 Created
  json.message "Signed up successfully."
end

json.data do
  json.id resource.id
  json.email resource.email
  json.first_name resource.first_name
  json.last_name resource.last_name
  json.jti resource.jti
end
