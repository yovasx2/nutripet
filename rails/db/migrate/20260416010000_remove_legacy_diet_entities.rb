class RemoveLegacyDietEntities < ActiveRecord::Migration[7.2]
  def change
    if foreign_key_exists?(:diet_prescriptions, :diet_formulas)
      remove_foreign_key :diet_prescriptions, :diet_formulas
    end
    if foreign_key_exists?(:diet_prescriptions, :diets)
      remove_foreign_key :diet_prescriptions, :diets
    end

    remove_column :diet_prescriptions, :diet_formula_id, :bigint if column_exists?(:diet_prescriptions, :diet_formula_id)
    remove_column :diet_prescriptions, :diet_id, :bigint if column_exists?(:diet_prescriptions, :diet_id)

    drop_table :diet_formulas if table_exists?(:diet_formulas)
    drop_table :recipe_ingredients if table_exists?(:recipe_ingredients)
    drop_table :recipe_contraindicated_conditions if table_exists?(:recipe_contraindicated_conditions)
    drop_table :recipe_contraindicated_allergens if table_exists?(:recipe_contraindicated_allergens)
    drop_table :diets if table_exists?(:diets)
  end
end
