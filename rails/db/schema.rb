# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_04_15_000018) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allergens", force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_allergens_on_category"
    t.index ["name"], name: "index_allergens_on_name", unique: true
  end

  create_table "commercial_foods", force: :cascade do |t|
    t.string "name", null: false
    t.string "brand"
    t.string "species", null: false
    t.string "life_stage"
    t.string "food_form", default: "dry"
    t.decimal "protein_min_pct", precision: 5, scale: 2
    t.decimal "fat_min_pct", precision: 5, scale: 2
    t.decimal "fiber_max_pct", precision: 5, scale: 2
    t.decimal "moisture_max_pct", precision: 5, scale: 2
    t.decimal "energy_kcal_per_kg", precision: 8, scale: 2
    t.string "label_standard"
    t.text "ingredients_list"
    t.boolean "is_active", default: true, null: false
    t.string "source", default: "manual", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_commercial_foods_on_is_active"
    t.index ["name"], name: "index_commercial_foods_on_name", unique: true
    t.index ["species"], name: "index_commercial_foods_on_species"
  end

  create_table "conditions", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "dietary_notes"
    t.string "species_scope", default: "both", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_conditions_on_name", unique: true
    t.index ["species_scope"], name: "index_conditions_on_species_scope"
  end

  create_table "diet_formulas", force: :cascade do |t|
    t.string "fingerprint", null: false
    t.string "name"
    t.string "species", null: false
    t.string "life_stage", null: false
    t.integer "condition_ids", default: [], array: true
    t.integer "allergen_ids", default: [], array: true
    t.jsonb "ingredient_composition", default: {}, null: false
    t.integer "upvotes_count", default: 0, null: false
    t.text "preparation_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fingerprint"], name: "index_diet_formulas_on_fingerprint", unique: true
    t.index ["species"], name: "index_diet_formulas_on_species"
    t.index ["upvotes_count"], name: "index_diet_formulas_on_upvotes_count"
  end

  create_table "diet_prescriptions", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.bigint "nutritional_standard_id", null: false
    t.bigint "diet_id"
    t.decimal "der_kcal", precision: 8, scale: 2, null: false
    t.decimal "daily_portion_g", precision: 8, scale: 2, null: false
    t.jsonb "engine_output", default: {}
    t.jsonb "llm_output", default: {}
    t.jsonb "final_output", default: {}
    t.jsonb "rejected_recipes", default: []
    t.string "status", default: "calculated", null: false
    t.string "llm_status"
    t.string "source", default: "engine", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "diet_formula_id"
    t.integer "upvotes_count", default: 0, null: false
    t.string "diet_type", default: "homemade", null: false
    t.string "preparation_style", default: "cooked", null: false
    t.string "standard_override"
    t.text "custom_allergens_notes"
    t.text "custom_conditions_notes"
    t.bigint "commercial_food_id"
    t.index ["commercial_food_id"], name: "index_diet_prescriptions_on_commercial_food_id"
    t.index ["diet_formula_id"], name: "index_diet_prescriptions_on_diet_formula_id"
    t.index ["diet_id"], name: "index_diet_prescriptions_on_diet_id"
    t.index ["engine_output"], name: "index_diet_prescriptions_on_engine_output", using: :gin
    t.index ["final_output"], name: "index_diet_prescriptions_on_final_output", using: :gin
    t.index ["nutritional_standard_id"], name: "index_diet_prescriptions_on_nutritional_standard_id"
    t.index ["pet_id"], name: "index_diet_prescriptions_on_pet_id"
    t.index ["status"], name: "index_diet_prescriptions_on_status"
  end

  create_table "diets", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "preparation_notes"
    t.string "species", null: false
    t.string "life_stage", null: false
    t.string "status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_diets_on_name", unique: true
    t.index ["species", "life_stage"], name: "index_diets_on_species_and_life_stage"
    t.index ["status"], name: "index_diets_on_status"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.string "source", default: "manual"
    t.boolean "is_custom", default: false, null: false
    t.string "species_safe", default: "both", null: false
    t.decimal "protein_g", precision: 6, scale: 2, default: "0.0"
    t.decimal "fat_g", precision: 6, scale: 2, default: "0.0"
    t.decimal "carbs_g", precision: 6, scale: 2, default: "0.0"
    t.decimal "fiber_g", precision: 6, scale: 2, default: "0.0"
    t.decimal "moisture_g", precision: 6, scale: 2, default: "0.0"
    t.decimal "energy_kcal", precision: 6, scale: 2, default: "0.0"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category", default: "protein", null: false
    t.string "safety_status", default: "safe", null: false
    t.text "safety_notes"
    t.integer "therapeutic_for", default: [], array: true
    t.boolean "raw_safe", default: false, null: false
    t.index ["category"], name: "index_ingredients_on_category"
    t.index ["is_custom"], name: "index_ingredients_on_is_custom"
    t.index ["name"], name: "index_ingredients_on_name", unique: true
    t.index ["safety_status"], name: "index_ingredients_on_safety_status"
    t.index ["species_safe"], name: "index_ingredients_on_species_safe"
    t.index ["therapeutic_for"], name: "index_ingredients_on_therapeutic_for", using: :gin
  end

  create_table "nutritional_standards", force: :cascade do |t|
    t.string "standard_name", null: false
    t.string "version"
    t.string "species", null: false
    t.string "life_stage", null: false
    t.decimal "protein_min_pct", precision: 5, scale: 2
    t.decimal "protein_max_pct", precision: 5, scale: 2
    t.decimal "fat_min_pct", precision: 5, scale: 2
    t.decimal "fat_max_pct", precision: 5, scale: 2
    t.decimal "fiber_max_pct", precision: 5, scale: 2
    t.decimal "moisture_max_pct", precision: 5, scale: 2
    t.decimal "energy_min_kcal_kg", precision: 7, scale: 2
    t.decimal "energy_max_kcal_kg", precision: 7, scale: 2
    t.jsonb "extra_constraints", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["extra_constraints"], name: "index_nutritional_standards_on_extra_constraints", using: :gin
    t.index ["species"], name: "index_nutritional_standards_on_species"
    t.index ["standard_name", "species", "life_stage"], name: "index_nutritional_standards_on_standard_species_life_stage", unique: true
  end

  create_table "pet_allergens", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.bigint "allergen_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allergen_id"], name: "index_pet_allergens_on_allergen_id"
    t.index ["pet_id", "allergen_id"], name: "index_pet_allergens_on_pet_id_and_allergen_id", unique: true
    t.index ["pet_id"], name: "index_pet_allergens_on_pet_id"
  end

  create_table "pet_conditions", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.bigint "condition_id", null: false
    t.text "notes"
    t.date "diagnosed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condition_id"], name: "index_pet_conditions_on_condition_id"
    t.index ["pet_id", "condition_id"], name: "index_pet_conditions_on_pet_id_and_condition_id", unique: true
    t.index ["pet_id"], name: "index_pet_conditions_on_pet_id"
  end

  create_table "pets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "species", null: false
    t.string "breed"
    t.decimal "weight_kg", precision: 5, scale: 2, null: false
    t.string "life_stage", null: false
    t.string "activity_level", null: false
    t.integer "body_condition_score", default: 5, null: false
    t.boolean "is_neutered", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["life_stage"], name: "index_pets_on_life_stage"
    t.index ["species"], name: "index_pets_on_species"
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "prescription_items", force: :cascade do |t|
    t.bigint "diet_prescription_id", null: false
    t.bigint "ingredient_id", null: false
    t.decimal "daily_amount_g", precision: 8, scale: 2, null: false
    t.decimal "pct_of_diet", precision: 5, scale: 2, null: false
    t.boolean "is_substitute", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diet_prescription_id", "ingredient_id"], name: "idx_on_diet_prescription_id_ingredient_id_64ef3d244a", unique: true
    t.index ["diet_prescription_id"], name: "index_prescription_items_on_diet_prescription_id"
    t.index ["ingredient_id"], name: "index_prescription_items_on_ingredient_id"
  end

  create_table "recipe_contraindicated_allergens", force: :cascade do |t|
    t.bigint "diet_id", null: false
    t.bigint "allergen_id", null: false
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allergen_id"], name: "index_recipe_contraindicated_allergens_on_allergen_id"
    t.index ["diet_id", "allergen_id"], name: "index_recipe_contraindicated_allergens_unique", unique: true
    t.index ["diet_id"], name: "index_recipe_contraindicated_allergens_on_diet_id"
  end

  create_table "recipe_contraindicated_conditions", force: :cascade do |t|
    t.bigint "diet_id", null: false
    t.bigint "condition_id", null: false
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condition_id"], name: "index_recipe_contraindicated_conditions_on_condition_id"
    t.index ["diet_id", "condition_id"], name: "index_recipe_contraindicated_conditions_unique", unique: true
    t.index ["diet_id"], name: "index_recipe_contraindicated_conditions_on_diet_id"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.bigint "diet_id", null: false
    t.bigint "ingredient_id", null: false
    t.decimal "base_percentage", precision: 5, scale: 2, null: false
    t.boolean "is_optional", default: false, null: false
    t.boolean "is_supplement", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diet_id", "ingredient_id"], name: "index_recipe_ingredients_on_diet_id_and_ingredient_id", unique: true
    t.index ["diet_id"], name: "index_recipe_ingredients_on_diet_id"
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "diet_prescriptions", "commercial_foods"
  add_foreign_key "diet_prescriptions", "diet_formulas"
  add_foreign_key "diet_prescriptions", "diets"
  add_foreign_key "diet_prescriptions", "nutritional_standards"
  add_foreign_key "diet_prescriptions", "pets"
  add_foreign_key "pet_allergens", "allergens"
  add_foreign_key "pet_allergens", "pets"
  add_foreign_key "pet_conditions", "conditions"
  add_foreign_key "pet_conditions", "pets"
  add_foreign_key "pets", "users"
  add_foreign_key "prescription_items", "diet_prescriptions"
  add_foreign_key "prescription_items", "ingredients"
  add_foreign_key "recipe_contraindicated_allergens", "allergens"
  add_foreign_key "recipe_contraindicated_allergens", "diets"
  add_foreign_key "recipe_contraindicated_conditions", "conditions"
  add_foreign_key "recipe_contraindicated_conditions", "diets"
  add_foreign_key "recipe_ingredients", "diets"
  add_foreign_key "recipe_ingredients", "ingredients"
end
