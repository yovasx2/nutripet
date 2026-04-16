class RenameMasterRecipesToDiets < ActiveRecord::Migration[7.2]
  def change
    # 1. Drop FK constraints that reference master_recipes
    remove_foreign_key :diet_prescriptions,                :master_recipes
    remove_foreign_key :recipe_ingredients,                :master_recipes
    remove_foreign_key :recipe_contraindicated_conditions, :master_recipes
    remove_foreign_key :recipe_contraindicated_allergens,  :master_recipes

    # 2. Rename the main table
    rename_table :master_recipes, :diets

    # 3. Rename FK columns in referencing tables
    rename_column :diet_prescriptions,                :master_recipe_id, :diet_id
    rename_column :recipe_ingredients,                :master_recipe_id, :diet_id
    rename_column :recipe_contraindicated_conditions, :master_recipe_id, :diet_id
    rename_column :recipe_contraindicated_allergens,  :master_recipe_id, :diet_id

    # 4. Re-add FK constraints pointing to the renamed diets table
    # Note: index renames are omitted — existing index names are cosmetic and still functional.
    add_foreign_key :diet_prescriptions,                :diets, column: :diet_id
    add_foreign_key :recipe_ingredients,                :diets, column: :diet_id
    add_foreign_key :recipe_contraindicated_conditions, :diets, column: :diet_id
    add_foreign_key :recipe_contraindicated_allergens,  :diets, column: :diet_id
  end
end
