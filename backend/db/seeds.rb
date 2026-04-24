carlos = User.find_or_create_by!(email: "carlos@nutripet.com") do |u|
  u.name     = "Carlos Pérez"
  u.password = "user1234"
  u.password_confirmation = "user1234"
end

carlos.pets.find_or_create_by!(name: "Rocky") do |p|
  p.breed               = "Labrador Retriever"
  p.sex                 = "male"
  p.age_years           = 3
  p.age_months          = 2
  p.weight              = 28.5
  p.activity_level      = "high"
  p.life_stage          = "adult"
  p.ecc_score           = 5
  p.reproductive_status = "none"
end

carlos.pets.find_or_create_by!(name: "Luna") do |p|
  p.breed               = "Poodle"
  p.sex                 = "female"
  p.age_years           = 1
  p.age_months          = 4
  p.weight              = 6.2
  p.activity_level      = "moderate"
  p.life_stage          = "adult"
  p.ecc_score           = 4
  p.reproductive_status = "none"
end

sofia = User.find_or_create_by!(email: "sofia@nutripet.com") do |u|
  u.name     = "Sofía Ramírez"
  u.password = "user1234"
  u.password_confirmation = "user1234"
end

sofia.pets.find_or_create_by!(name: "Canela") do |p|
  p.breed               = "Golden Retriever"
  p.sex                 = "female"
  p.age_years           = 5
  p.age_months          = 0
  p.weight              = 24.0
  p.activity_level      = "moderate"
  p.life_stage          = "adult"
  p.ecc_score           = 6
  p.reproductive_status = "none"
end

sofia.pets.find_or_create_by!(name: "Thor") do |p|
  p.breed               = "Pastor Alemán"
  p.sex                 = "male"
  p.age_years           = 8
  p.age_months          = 6
  p.weight              = 35.0
  p.activity_level      = "low"
  p.life_stage          = "senior"
  p.ecc_score           = 5
  p.reproductive_status = "none"
end

sofia.pets.find_or_create_by!(name: "Gordis") do |p|
  p.breed               = "Pug"
  p.sex                 = "male"
  p.age_years           = 4
  p.age_months          = 0
  p.weight              = 18.0
  p.activity_level      = "low"
  p.life_stage          = "adult"
  p.ecc_score           = 9
  p.reproductive_status = "none"
end

sofia.pets.find_or_create_by!(name: "Skeletor") do |p|
  p.breed               = "Greyhound"
  p.sex                 = "male"
  p.age_years           = 2
  p.age_months          = 3
  p.weight              = 12.0
  p.activity_level      = "low"
  p.life_stage          = "adult"
  p.ecc_score           = 1
  p.reproductive_status = "none"
end

puts "Seeded users:"
puts "  carlos@nutripet.com / user1234 — Rocky, Luna"
puts "  sofia@nutripet.com / user1234 — Canela, Thor, Gordis (ECC 9), Skeletor (ECC 1)"
