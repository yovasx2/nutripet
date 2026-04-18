# db/seeds.rb — NutriPet MVP

require "json"

puts "Seeding ingredients..."
ingredients_path = Rails.root.join("db/usda/ingredients.json")
ingredients = JSON.parse(File.read(ingredients_path), symbolize_names: true)

common_attrs = { is_custom: false, source: "USDA FoodData Central" }

count = 0
ingredients.each do |attrs|
  Ingredient.find_or_initialize_by(name: attrs[:name]).tap do |ing|
    ing.assign_attributes(common_attrs.merge(attrs))
    ing.save!
  end
  count += 1
end

puts "Seeded #{count} ingredients"
puts "  Safe/Caution: #{Ingredient.non_toxic.count}"
puts "  Toxic: #{Ingredient.where(safety_status: 'toxic').count}"
puts "  Proteins: #{Ingredient.proteins.non_toxic.count}"
puts "  Vegetables: #{Ingredient.vegetables.non_toxic.count}"
puts "  Carbs: #{Ingredient.carbs.non_toxic.count}"
puts "  Fats: #{Ingredient.fats.non_toxic.count}"

puts "\nSeeding demo user..."
user = User.find_or_create_by!(email: "user@nutripet") do |u|
  u.password = "nutri1234"
end
puts "Seeded demo user: #{user.email}"

puts "\nSeeding demo pet..."
pet = Pet.find_or_create_by!(name: "Bruno", user: user) do |p|
  p.species              = "dog"
  p.breed                = "Chihuahua"
  p.sex                  = "male"
  p.weight_kg            = 4.1
  p.age_months           = 96
  p.activity_level       = "low"
  p.body_condition_score = 7
  p.is_neutered          = true
end
puts "Seeded demo pet: #{pet.name} (#{pet.breed}, #{pet.weight_kg} kg)"

pet2 = Pet.find_or_create_by!(name: "Hércules", user: user) do |p|
  p.species              = "dog"
  p.breed                = "Mestizo"
  p.sex                  = "male"
  p.weight_kg            = 18.32
  p.age_months           = 83
  p.activity_level       = "low"
  p.body_condition_score = 3
  p.is_neutered          = true
end
puts "Seeded demo pet: #{pet2.name} (#{pet2.breed}, #{pet2.weight_kg} kg)"

pet3 = Pet.find_or_create_by!(name: "Kitty", user: user) do |p|
  p.species              = "dog"
  p.breed                = "Mestiza"
  p.sex                  = "female"
  p.weight_kg            = 13.0
  p.age_months           = 143
  p.activity_level       = "sedentary"
  p.body_condition_score = 7
  p.is_neutered          = false
  p.is_pregnant          = false
  p.is_lactating         = true
end
puts "Seeded demo pet: #{pet3.name} (#{pet3.breed}, #{pet3.weight_kg} kg)"

pet4 = Pet.find_or_create_by!(name: "Esqueletor", user: user) do |p|
  p.species              = "dog"
  p.breed                = "Mestizo"
  p.sex                  = "male"
  p.weight_kg            = 18.32
  p.age_months           = 83
  p.activity_level       = "low"
  p.body_condition_score = 1
  p.is_neutered          = true
end
puts "Seeded demo pet: #{pet4.name} (#{pet4.breed}, #{pet4.weight_kg} kg)"

pet5 = Pet.find_or_create_by!(name: "Gordis", user: user) do |p|
  p.species              = "dog"
  p.breed                = "Mestiza"
  p.sex                  = "female"
  p.weight_kg            = 13.0
  p.age_months           = 143
  p.activity_level       = "sedentary"
  p.body_condition_score = 9
  p.is_neutered          = false
  p.is_pregnant          = false
  p.is_lactating         = true
end
puts "Seeded demo pet: #{pet5.name} (#{pet5.breed}, #{pet5.weight_kg} kg)"
