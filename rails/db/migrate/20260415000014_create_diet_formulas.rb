class CreateDietFormulas < ActiveRecord::Migration[7.2]
  def change
    create_table :diet_formulas do |t|
      t.string  :fingerprint,           null: false
      t.string  :name
      t.string  :species,               null: false
      t.string  :life_stage,            null: false
      t.integer :condition_ids,         array: true, default: []
      t.integer :allergen_ids,          array: true, default: []
      t.jsonb   :ingredient_composition, null: false, default: {}
      t.integer :upvotes_count,         null: false, default: 0
      t.text    :preparation_notes
      t.timestamps
    end

    add_index :diet_formulas, :fingerprint, unique: true
    add_index :diet_formulas, :species
    add_index :diet_formulas, :upvotes_count
  end
end
