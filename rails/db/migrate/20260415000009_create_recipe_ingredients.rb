class CreateRecipeIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :recipe_ingredients do |t|
      t.references :master_recipe, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.decimal :base_percentage, precision: 5, scale: 2, null: false  # % of total diet by weight
      t.boolean :is_optional, default: false, null: false
      t.boolean :is_supplement, default: false, null: false

      t.timestamps
    end

    add_index :recipe_ingredients, [:master_recipe_id, :ingredient_id], unique: true
  end
end
