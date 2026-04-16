class CreateMasterRecipes < ActiveRecord::Migration[7.2]
  def change
    create_table :master_recipes do |t|
      t.string :name, null: false
      t.text :description
      t.text :preparation_notes
      t.string :species, null: false          # dog | cat
      t.string :life_stage, null: false       # puppy|kitten|adult|senior|pregnant|lactating|all_life_stages
      t.string :status, default: "draft", null: false  # draft | active | archived

      t.timestamps
    end

    add_index :master_recipes, :name, unique: true
    add_index :master_recipes, [:species, :life_stage]
    add_index :master_recipes, :status
  end
end
