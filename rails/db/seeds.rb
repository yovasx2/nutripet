# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

superadmin_email = ENV.fetch("SUPERADMIN_EMAIL", "super@nutripet")
superadmin_password = ENV.fetch("SUPERADMIN_PASSWORD", "super")

superadmin = User.find_or_initialize_by(email: superadmin_email)
superadmin.assign_attributes(
  first_name: "Super",
  last_name: "Admin",
  role: :superadmin,
  password: superadmin_password,
  password_confirmation: superadmin_password
)
superadmin.save!
puts "Created or updated superadmin: #{superadmin.email}"

user_email = ENV.fetch("DEFAULT_USER_EMAIL", "user@nutripet")
user_password = ENV.fetch("DEFAULT_USER_PASSWORD", "user")

default_user = User.find_or_initialize_by(email: user_email)
default_user.assign_attributes(
  first_name: "Usuario",
  last_name: "NutriPet",
  role: :user,
  password: user_password,
  password_confirmation: user_password
)
default_user.save!
puts "Created or updated default user: #{default_user.email}"
