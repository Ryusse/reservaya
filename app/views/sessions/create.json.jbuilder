json.message "Bienvenido, #{@user.name}"
json.token @token
json.user do
  json.id @user.id
  json.name @user.name
  json.email @user.email
  json.role @user.role
end