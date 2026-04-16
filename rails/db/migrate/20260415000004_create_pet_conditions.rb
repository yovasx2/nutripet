class CreatePetConditions < ActiveRecord::Migration[7.2]
  def change
    create_table :pet_conditions do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :condition, null: false, foreign_key: true
      t.text :notes
      t.date :diagnosed_at

      t.timestamps
    end

    add_index :pet_conditions, [:pet_id, :condition_id], unique: true
  end
end
