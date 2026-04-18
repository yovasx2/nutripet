# frozen_string_literal: true

# Usage:
#   USDA_API_KEY=xxxx bundle exec ruby db/usda/usda_populate_ingredients.rb
#
# Reads the ingredient list from db/seeds.rb, fetches USDA macros/micros when possible,
# infers functional scores, and writes db/usda/ingredients.json.

require "json"
require "net/http"
require "uri"

API_KEY = ENV.fetch("USDA_API_KEY", "").strip
BASE_URL = "https://api.nal.usda.gov/fdc/v1".freeze
SEEDS_PATH = File.expand_path("../seeds.rb", __dir__)
OUTPUT_PATH = File.expand_path("ingredients.json", __dir__)

NUTRIENT_NAME_MAP = {
  energy_kcal: "Energy",
  protein_g: "Protein",
  fat_g: "Total lipid (fat)",
  carbs_g: "Carbohydrate, by difference",
  fiber_g: "Fiber, total dietary",
  moisture_g: "Water",
  calcium_mg: "Calcium, Ca",
  phosphorus_mg: "Phosphorus, P",
  magnesium_mg: "Magnesium, Mg",
  potassium_mg: "Potassium, K",
  zinc_mg: "Zinc, Zn",
  iron_mg: "Iron, Fe",
  copper_mg: "Copper, Cu",
  iodine_mcg: "Iodine, I",
  selenium_mcg: "Selenium, Se"
}.freeze

NUTRIENT_NUMBER_MAP = {
  energy_kcal: "1008",
  protein_g: "1003",
  fat_g: "1004",
  carbs_g: "1005",
  fiber_g: "1079",
  moisture_g: "1051",
  calcium_mg: "1087",
  phosphorus_mg: "1091",
  magnesium_mg: "1090",
  potassium_mg: "1092",
  zinc_mg: "1095",
  iron_mg: "1089",
  copper_mg: "1098",
  iodine_mcg: "1100",
  selenium_mcg: "1103"
}.freeze

TOKEN_TRANSLATIONS = {
  "pechuga" => "breast", "muslo" => "thigh", "pollo" => "chicken", "pavo" => "turkey",
  "molida" => "ground", "res" => "beef", "corazon" => "heart", "higado" => "liver",
  "rinon" => "kidney", "pulmon" => "lung", "molleja" => "gizzard", "cerdo" => "pork",
  "costilla" => "rib", "lomo" => "loin", "atun" => "tuna", "sardinas" => "sardines",
  "bacalao" => "cod", "huevo" => "egg", "clara" => "white", "cordero" => "lamb",
  "conejo" => "rabbit", "pato" => "duck", "ternera" => "veal", "zanahoria" => "carrot",
  "calabacita" => "zucchini", "calabaza" => "pumpkin", "castilla" => "", "espinaca" => "spinach",
  "brocoli" => "broccoli", "coliflor" => "cauliflower", "chayote" => "chayote", "nopal" => "cactus",
  "ejotes" => "green beans", "chicharos" => "peas", "jicama" => "jicama", "betabel" => "beet",
  "pepino" => "cucumber", "apio" => "celery", "esparrago" => "asparagus", "repollo" => "cabbage",
  "lechuga" => "lettuce", "romana" => "romaine", "pimiento" => "pepper", "rojo" => "red",
  "jitomate" => "tomato", "berros" => "watercress", "arandano" => "blueberry", "azul" => "",
  "manzana" => "apple", "sandia" => "watermelon", "papaya" => "papaya", "madura" => "ripe",
  "mango" => "mango", "pera" => "pear", "fresas" => "strawberries", "frambuesas" => "raspberries",
  "platano" => "banana", "amaranto" => "amaranth", "brotes" => "sprouts", "alfalfa" => "alfalfa",
  "remolacha" => "beet", "hoja" => "greens", "verdolaga" => "purslane", "flor" => "flower",
  "guayaba" => "guava", "tuna" => "prickly pear", "tejocote" => "hawthorn", "arroz" => "rice",
  "blanco" => "white", "integral" => "brown", "avena" => "oatmeal", "camote" => "sweet potato",
  "papa" => "potato", "quinoa" => "quinoa", "cebada" => "barley", "perlada" => "pearled",
  "mijo" => "millet", "yuca" => "cassava", "elote" => "corn", "trigo" => "buckwheat",
  "sarraceno" => "", "macho" => "plantain", "lentejas" => "lentils", "garbanzos" => "chickpeas",
  "frijoles" => "beans", "negros" => "black", "habas" => "fava", "edamame" => "edamame",
  "pintos" => "pinto", "blancos" => "white", "bayo" => "pinto", "tortilla" => "tortilla",
  "maiz" => "corn", "aceite" => "oil", "oliva" => "olive", "virgen" => "extra virgin",
  "girasol" => "sunflower", "canola" => "canola", "coco" => "coconut", "semillas" => "seeds",
  "chia" => "chia", "linaza" => "flax", "aguacate" => "avocado", "pulpa" => "pulp",
  "cebolla" => "onion", "ajo" => "garlic", "puerro" => "leek", "uvas" => "grapes",
  "pasas" => "raisins", "nuez" => "nut", "pecana" => "pecan", "nogal" => "walnut",
  "xilitol" => "xylitol", "cafe" => "coffee", "chocolate" => "dark chocolate", "amargo" => "dark"
}.freeze

def load_seed_ingredients
  content = File.read(SEEDS_PATH)
  start_idx = content.index("ingredients = [")
  end_idx = content.index("\n]\n\ncommon_attrs")
  if start_idx.nil? || end_idx.nil?
    return load_existing_json
  end

  literal = content[(start_idx + "ingredients = ".length)..(end_idx + 1)]
  ingredients = eval(literal, binding, "seeds_ingredients")
  unless ingredients.is_a?(Array)
    return load_existing_json
  end
  ingredients
end

def load_existing_json
  return [] unless File.exist?(OUTPUT_PATH)

  parsed = JSON.parse(File.read(OUTPUT_PATH), symbolize_names: true)
  parsed.is_a?(Array) ? parsed : []
end

def get_json(url)
  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  nil
end

def candidate_queries(name)
  ascii_name = name.unicode_normalize(:nfkd).encode("ASCII", undef: :replace, invalid: :replace, replace: "").downcase
  english_tokens = ascii_name.split(/\s+/).map { |token| TOKEN_TRANSLATIONS.fetch(token, token) }.reject(&:empty?)
  english_name = english_tokens.join(" ").strip

  [
    "#{english_name} raw",
    "#{english_name} cooked",
    english_name,
    "#{ascii_name} raw",
    ascii_name
  ].uniq.reject(&:empty?)
end

def find_best_food(name)
  return [nil, nil] if API_KEY.empty?

  candidate_queries(name).each do |query|
    search_url = "#{BASE_URL}/foods/search?query=#{URI.encode_www_form_component(query)}&pageSize=8&api_key=#{API_KEY}"
    search = get_json(search_url)
    foods = search && search["foods"] || []
    next if foods.empty?

    chosen = foods.find do |food|
      desc = (food["description"] || "").downcase
      query_head = query.split.first.to_s.downcase
      desc.include?(query_head)
    end || foods.first

    return [chosen, query]
  end

  [nil, nil]
end

def extract_nutrient(food_nutrients, nutrient_name, nutrient_number = nil)
  match = nil

  if nutrient_number
    match = food_nutrients.find do |n|
      number = n.dig("nutrient", "number") || n["nutrientNumber"]
      number.to_s == nutrient_number
    end
  end

  match ||= food_nutrients.find do |n|
    n_name = n.dig("nutrient", "name") || n["nutrientName"]
    n_name.to_s.casecmp?(nutrient_name)
  end

  (match && (match["amount"] || match["value"]) || 0).to_f
end

def extract_omega3(food_nutrients)
  rows = food_nutrients.select do |n|
    n_name = (n.dig("nutrient", "name") || n["nutrientName"] || "").downcase
    n_name.include?("omega-3") || n_name.include?("18:3")
  end
  rows.sum { |row| (row["amount"] || row["value"] || 0).to_f }
end

def fetch_usda_profile(name)
  food, used_query = find_best_food(name)
  return nil if food.nil?

  detail_url = "#{BASE_URL}/food/#{food["fdcId"]}?api_key=#{API_KEY}"
  detail = get_json(detail_url)
  return nil if detail.nil?

  nutrients = detail["foodNutrients"] || []
  profile = {
    fdc_id: food["fdcId"],
    usda_description: detail["description"] || food["description"],
    usda_query: used_query
  }

  NUTRIENT_NAME_MAP.each do |field, nutrient_name|
    profile[field] = extract_nutrient(nutrients, nutrient_name, NUTRIENT_NUMBER_MAP[field]).round(2)
  end

  profile[:omega3_mg] = extract_omega3(nutrients).round(2)
  profile
end

def clamp(value, min, max)
  [[value, min].max, max].min
end

def estimate_scores(attrs)
  safety_status = attrs[:safety_status].to_s
  category = attrs[:category].to_s
  fiber = attrs[:fiber_g].to_f
  fat = attrs[:fat_g].to_f
  protein = attrs[:protein_g].to_f
  omega3_mg = attrs[:omega3_mg].to_f

  digestibility = case category
  when "protein"
    7 + (protein >= 20 ? 1 : 0) - (fat > 20 ? 1 : 0)
  when "carb"
    6 - (fiber > 7 ? 1 : 0)
  when "vegetable"
    6 - (fiber > 4 ? 1 : 0)
  when "fat"
    7 - (fat > 80 ? 1 : 0)
  else
    6
  end

  gas_risk = case category
  when "carb", "vegetable"
    2 + (fiber / 3.0).round
  when "protein"
    2 + (fat / 8.0).round
  else
    3
  end

  stool_firming = clamp((6 + (fiber <= 3 ? 1 : 0) - (fat > 20 ? 2 : 0)).round, 1, 10)
  omega_score = if omega3_mg >= 1000
    10
  elsif omega3_mg >= 500
    8
  elsif omega3_mg >= 100
    6
  elsif omega3_mg > 0
    4
  else
    2
  end

  if safety_status == "toxic"
    digestibility = 1
    gas_risk = [gas_risk, 7].max
    stool_firming = [stool_firming, 3].min
    omega_score = [omega_score, 2].min
  end

  {
    digestibility: clamp(digestibility, 1, 10),
    gas_risk: clamp(gas_risk, 1, 10),
    stool_firming: clamp(stool_firming, 1, 10),
    omega3: clamp(omega_score, 1, 10)
  }
end

def build_record(seed_attrs)
  attrs = seed_attrs.transform_keys(&:to_sym)

  usda_profile = fetch_usda_profile(attrs[:name])
  if usda_profile
    attrs.merge!(
      energy_kcal: usda_profile[:energy_kcal] || attrs[:energy_kcal],
      protein_g: usda_profile[:protein_g] || attrs[:protein_g],
      fat_g: usda_profile[:fat_g] || attrs[:fat_g],
      carbs_g: usda_profile[:carbs_g] || attrs[:carbs_g],
      fiber_g: usda_profile[:fiber_g] || attrs[:fiber_g] || 0,
      moisture_g: usda_profile[:moisture_g] || attrs[:moisture_g],
      calcium_mg: usda_profile[:calcium_mg] || 0,
      phosphorus_mg: usda_profile[:phosphorus_mg] || 0,
      magnesium_mg: usda_profile[:magnesium_mg] || 0,
      potassium_mg: usda_profile[:potassium_mg] || 0,
      zinc_mg: usda_profile[:zinc_mg] || 0,
      iron_mg: usda_profile[:iron_mg] || 0,
      copper_mg: usda_profile[:copper_mg] || 0,
      iodine_mcg: usda_profile[:iodine_mcg] || 0,
      selenium_mcg: usda_profile[:selenium_mcg] || 0,
      omega3_mg: usda_profile[:omega3_mg] || 0,
      notes: "USDA FDC #{usda_profile[:fdc_id]} - #{usda_profile[:usda_description]}"
    )
  else
    attrs.merge!(
      fiber_g: attrs[:fiber_g] || 0,
      calcium_mg: 0,
      phosphorus_mg: 0,
      magnesium_mg: 0,
      potassium_mg: 0,
      zinc_mg: 0,
      iron_mg: 0,
      copper_mg: 0,
      iodine_mcg: 0,
      selenium_mcg: 0,
      omega3_mg: 0
    )
  end

  attrs.merge!(estimate_scores(attrs))
  attrs[:source] = "USDA FoodData Central"
  attrs[:is_custom] = false

  attrs
end

seed_ingredients = load_seed_ingredients
raise "No ingredient list found in db/seeds.rb or db/usda/ingredients.json" if seed_ingredients.empty?
puts "Loaded #{seed_ingredients.size} ingredients from db/seeds.rb"

records = seed_ingredients.map.with_index(1) do |seed_attrs, idx|
  puts "[#{idx}/#{seed_ingredients.size}] Processing #{seed_attrs[:name]}"
  build_record(seed_attrs)
end

File.write(OUTPUT_PATH, JSON.pretty_generate(records))
puts "Wrote #{records.size} records to #{OUTPUT_PATH}"
