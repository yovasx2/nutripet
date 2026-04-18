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

ActiveRecord::Schema[7.2].define(version: 2026_04_18_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "diet_items", force: :cascade do |t|
    t.bigint "diet_id", null: false
    t.bigint "ingredient_id", null: false
    t.float "daily_amount_g", null: false
    t.float "pct_of_diet", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diet_id", "ingredient_id"], name: "index_diet_items_on_diet_id_and_ingredient_id", unique: true
    t.index ["diet_id"], name: "index_diet_items_on_diet_id"
    t.index ["ingredient_id"], name: "index_diet_items_on_ingredient_id"
  end

  create_table "diets", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.float "der_kcal", null: false
    t.float "daily_portion_g", null: false
    t.string "preparation_style", default: "cooked", null: false
    t.jsonb "engine_output", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_diets_on_pet_id"
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
    t.decimal "calcium_mg", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "phosphorus_mg", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "magnesium_mg", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "potassium_mg", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "zinc_mg", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "iron_mg", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "copper_mg", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "iodine_mcg", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "selenium_mcg", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "omega3_mg", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "digestibility", default: 5, null: false
    t.integer "gas_risk", default: 5, null: false
    t.integer "stool_firming", default: 5, null: false
    t.integer "omega3", default: 5, null: false
    t.index ["category"], name: "index_ingredients_on_category"
    t.index ["is_custom"], name: "index_ingredients_on_is_custom"
    t.index ["name"], name: "index_ingredients_on_name", unique: true
    t.index ["safety_status"], name: "index_ingredients_on_safety_status"
    t.index ["species_safe"], name: "index_ingredients_on_species_safe"
    t.index ["therapeutic_for"], name: "index_ingredients_on_therapeutic_for", using: :gin
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
    t.string "sex", default: "female", null: false
    t.integer "age_months"
    t.boolean "is_pregnant", default: false, null: false
    t.boolean "is_lactating", default: false, null: false
    t.index ["life_stage"], name: "index_pets_on_life_stage"
    t.index ["sex"], name: "index_pets_on_sex"
    t.index ["species"], name: "index_pets_on_species"
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "premixes", force: :cascade do |t|
    t.string "name", null: false
    t.string "species_safe", default: "both", null: false
    t.boolean "active", default: true, null: false
    t.text "description"
    t.text "notes"
    t.decimal "calcium_mg_per_g", precision: 10, scale: 4, default: "0.0", null: false
    t.decimal "phosphorus_mg_per_g", precision: 10, scale: 4, default: "0.0", null: false
    t.decimal "magnesium_mg_per_g", precision: 10, scale: 4, default: "0.0", null: false
    t.decimal "potassium_mg_per_g", precision: 10, scale: 4, default: "0.0", null: false
    t.decimal "zinc_mg_per_g", precision: 10, scale: 4, default: "0.0", null: false
    t.decimal "iron_mg_per_g", precision: 10, scale: 4, default: "0.0", null: false
    t.decimal "copper_mg_per_g", precision: 10, scale: 4, default: "0.0", null: false
    t.decimal "iodine_mcg_per_g", precision: 10, scale: 4, default: "0.0", null: false
    t.decimal "selenium_mcg_per_g", precision: 10, scale: 4, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "species_safe"], name: "index_premixes_on_active_and_species_safe"
    t.index ["name"], name: "index_premixes_on_name", unique: true
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

  add_foreign_key "diet_items", "diets"
  add_foreign_key "diet_items", "ingredients"
  add_foreign_key "diets", "pets"
  add_foreign_key "pets", "users"
end
