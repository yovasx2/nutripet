# Create a test user
User.find_or_create_by!(email: "user@nutripet.com") do |user|
  user.name = "Carlos Pérez"
  user.password = "user1234"
  user.password_confirmation = "user1234"
end

puts "Seeded 1 test user: user@nutripet.com / user1234"
