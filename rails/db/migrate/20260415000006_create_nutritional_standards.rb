class CreateNutritionalStandards < ActiveRecord::Migration[7.2]
  def change
    create_table :nutritional_standards do |t|
      t.string :standard_name, null: false   # AAFCO | FEDIAF
      t.string :version                       # e.g. "2023"
      t.string :species, null: false          # dog | cat
      t.string :life_stage, null: false       # puppy|kitten|adult|senior|pregnant|lactating|all_life_stages
      # Macronutrient bounds (% of dry matter)
      t.decimal :protein_min_pct, precision: 5, scale: 2
      t.decimal :protein_max_pct, precision: 5, scale: 2
      t.decimal :fat_min_pct, precision: 5, scale: 2
      t.decimal :fat_max_pct, precision: 5, scale: 2
      t.decimal :fiber_max_pct, precision: 5, scale: 2
      t.decimal :moisture_max_pct, precision: 5, scale: 2
      # Energy bounds (kcal metabolizable energy per kg dry matter)
      t.decimal :energy_min_kcal_kg, precision: 7, scale: 2
      t.decimal :energy_max_kcal_kg, precision: 7, scale: 2
      # Extra constraints as JSONB for additional nutrients
      t.jsonb :extra_constraints, default: {}

      t.timestamps
    end

    add_index :nutritional_standards, [:standard_name, :species, :life_stage], unique: true, name: "index_nutritional_standards_on_standard_species_life_stage"
    add_index :nutritional_standards, :species
    add_index :nutritional_standards, :extra_constraints, using: :gin
  end
end
