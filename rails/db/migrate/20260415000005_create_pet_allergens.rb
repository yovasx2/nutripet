class CreatePetAllergens < ActiveRecord::Migration[7.2]
  def change
    create_table :pet_allergens do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :allergen, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end

    add_index :pet_allergens, [:pet_id, :allergen_id], unique: true
  end
end
