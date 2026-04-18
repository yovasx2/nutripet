class AddMicrosAndScoresToIngredients < ActiveRecord::Migration[7.2]
  def change
    add_column :ingredients, :calcium_mg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :calcium_mg)
    add_column :ingredients, :phosphorus_mg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :phosphorus_mg)
    add_column :ingredients, :magnesium_mg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :magnesium_mg)
    add_column :ingredients, :potassium_mg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :potassium_mg)
    add_column :ingredients, :zinc_mg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :zinc_mg)
    add_column :ingredients, :iron_mg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :iron_mg)
    add_column :ingredients, :copper_mg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :copper_mg)
    add_column :ingredients, :iodine_mcg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :iodine_mcg)
    add_column :ingredients, :selenium_mcg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :selenium_mcg)
    add_column :ingredients, :omega3_mg, :decimal, precision: 8, scale: 2, default: 0.0, null: false unless column_exists?(:ingredients, :omega3_mg)

    add_column :ingredients, :digestibility, :integer, default: 5, null: false unless column_exists?(:ingredients, :digestibility)
    add_column :ingredients, :gas_risk, :integer, default: 5, null: false unless column_exists?(:ingredients, :gas_risk)
    add_column :ingredients, :stool_firming, :integer, default: 5, null: false unless column_exists?(:ingredients, :stool_firming)
    add_column :ingredients, :omega3, :integer, default: 5, null: false unless column_exists?(:ingredients, :omega3)
  end
end
