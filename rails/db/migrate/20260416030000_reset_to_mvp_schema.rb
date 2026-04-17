class ResetToMvpSchema < ActiveRecord::Migration[7.2]
  def change
    # Drop legacy tables
    drop_table :prescription_items, if_exists: true
    drop_table :diet_prescriptions, if_exists: true
    drop_table :pet_allergens, if_exists: true
    drop_table :pet_conditions, if_exists: true
    drop_table :allergens, if_exists: true
    drop_table :conditions, if_exists: true
    drop_table :commercial_foods, if_exists: true
    drop_table :nutritional_standards, if_exists: true

    # Create diets table
    create_table :diets do |t|
      t.references :pet, null: false, foreign_key: true
      t.float :der_kcal, null: false
      t.float :daily_portion_g, null: false
      t.string :preparation_style, null: false, default: "cooked"
      t.jsonb :engine_output, null: false, default: {}
      t.timestamps
    end

    # Create diet_items table
    create_table :diet_items do |t|
      t.references :diet, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.float :daily_amount_g, null: false
      t.float :pct_of_diet, null: false
      t.timestamps
    end

    add_index :diet_items, [:diet_id, :ingredient_id], unique: true
  end
end
