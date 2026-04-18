class CreatePremixes < ActiveRecord::Migration[7.2]
  def change
    create_table :premixes do |t|
      t.string :name, null: false
      t.string :species_safe, null: false, default: "both"
      t.boolean :active, null: false, default: true
      t.text :description
      t.text :notes
      t.decimal :calcium_mg_per_g, precision: 10, scale: 4, null: false, default: "0.0"
      t.decimal :phosphorus_mg_per_g, precision: 10, scale: 4, null: false, default: "0.0"
      t.decimal :magnesium_mg_per_g, precision: 10, scale: 4, null: false, default: "0.0"
      t.decimal :potassium_mg_per_g, precision: 10, scale: 4, null: false, default: "0.0"
      t.decimal :zinc_mg_per_g, precision: 10, scale: 4, null: false, default: "0.0"
      t.decimal :iron_mg_per_g, precision: 10, scale: 4, null: false, default: "0.0"
      t.decimal :copper_mg_per_g, precision: 10, scale: 4, null: false, default: "0.0"
      t.decimal :iodine_mcg_per_g, precision: 10, scale: 4, null: false, default: "0.0"
      t.decimal :selenium_mcg_per_g, precision: 10, scale: 4, null: false, default: "0.0"

      t.timestamps
    end

    add_index :premixes, :name, unique: true
    add_index :premixes, [:active, :species_safe]
  end
end
