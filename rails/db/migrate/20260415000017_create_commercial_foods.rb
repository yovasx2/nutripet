class CreateCommercialFoods < ActiveRecord::Migration[7.2]
  def change
    create_table :commercial_foods do |t|
      t.string  :name,               null: false
      t.string  :brand
      t.string  :species,            null: false                # dog / cat / both
      t.string  :life_stage                                     # adult / puppy / all_life_stages
      t.string  :food_form,          default: "dry"            # dry / wet / semi_moist
      # Guaranteed Analysis values (as-fed %) as printed on the label
      t.decimal :protein_min_pct,    precision: 5, scale: 2
      t.decimal :fat_min_pct,        precision: 5, scale: 2
      t.decimal :fiber_max_pct,      precision: 5, scale: 2
      t.decimal :moisture_max_pct,   precision: 5, scale: 2
      # Metabolisable energy per kg of food (as-fed basis)
      t.decimal :energy_kcal_per_kg, precision: 8, scale: 2
      # Which standard the label claims compliance with
      t.string  :label_standard                                 # e.g. "AAFCO", "FEDIAF"
      t.text    :ingredients_list                                # raw text from label
      t.boolean :is_active,          null: false, default: true
      t.string  :source,             null: false, default: "manual" # manual / import
      t.text    :notes
      t.timestamps
    end

    add_index :commercial_foods, :name, unique: true
    add_index :commercial_foods, :species
    add_index :commercial_foods, :is_active

    # Link prescriptions to a commercial food product (optional)
    add_reference :diet_prescriptions, :commercial_food, null: true, foreign_key: true
  end
end
