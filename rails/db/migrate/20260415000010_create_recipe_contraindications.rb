class CreateRecipeContraindications < ActiveRecord::Migration[7.2]
  def change
    # Recipes that cannot be used when a pet has a specific condition
    create_table :recipe_contraindicated_conditions do |t|
      t.references :master_recipe, null: false, foreign_key: true
      t.references :condition, null: false, foreign_key: true
      t.text :reason

      t.timestamps
    end

    add_index :recipe_contraindicated_conditions,
              [:master_recipe_id, :condition_id],
              unique: true,
              name: "index_recipe_contraindicated_conditions_unique"

    # Recipes that cannot be used when a pet has a specific allergen
    create_table :recipe_contraindicated_allergens do |t|
      t.references :master_recipe, null: false, foreign_key: true
      t.references :allergen, null: false, foreign_key: true
      t.text :reason

      t.timestamps
    end

    add_index :recipe_contraindicated_allergens,
              [:master_recipe_id, :allergen_id],
              unique: true,
              name: "index_recipe_contraindicated_allergens_unique"
  end
end
