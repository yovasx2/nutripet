class CreateIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.string :source, default: "manual"  # USDA | INIFAP | manual
      t.boolean :is_custom, default: false, null: false
      t.string :species_safe, default: "both", null: false  # dog | cat | both | none
      # Nutritional content per 100g as-fed
      t.decimal :protein_g, precision: 6, scale: 2, default: 0
      t.decimal :fat_g, precision: 6, scale: 2, default: 0
      t.decimal :carbs_g, precision: 6, scale: 2, default: 0
      t.decimal :fiber_g, precision: 6, scale: 2, default: 0
      t.decimal :moisture_g, precision: 6, scale: 2, default: 0
      t.decimal :energy_kcal, precision: 6, scale: 2, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :ingredients, :name, unique: true
    add_index :ingredients, :species_safe
    add_index :ingredients, :is_custom
  end
end
