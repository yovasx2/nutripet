class CreateAllergens < ActiveRecord::Migration[7.2]
  def change
    create_table :allergens do |t|
      t.string :name, null: false
      t.string :category, null: false  # protein | grain | vegetable | other

      t.timestamps
    end

    add_index :allergens, :name, unique: true
    add_index :allergens, :category
  end
end
