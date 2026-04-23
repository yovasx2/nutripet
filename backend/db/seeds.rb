# Create a test user
User.find_or_create_by!(email: "test@nutripet.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
end

puts "Seeded 1 test user: test@nutripet.com / password123"
