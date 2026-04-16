class CreatePrescriptionItems < ActiveRecord::Migration[7.2]
  def change
    create_table :prescription_items do |t|
      t.references :diet_prescription, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.decimal :daily_amount_g, precision: 8, scale: 2, null: false
      t.decimal :pct_of_diet, precision: 5, scale: 2, null: false
      t.boolean :is_substitute, default: false, null: false  # true if LLM replaced original ingredient

      t.timestamps
    end

    add_index :prescription_items, [:diet_prescription_id, :ingredient_id], unique: true
  end
end
