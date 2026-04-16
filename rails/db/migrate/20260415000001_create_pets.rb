class CreatePets < ActiveRecord::Migration[7.2]
  def change
    create_table :pets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :species, null: false       # dog | cat
      t.string :breed
      t.decimal :weight_kg, precision: 5, scale: 2, null: false
      t.string :life_stage, null: false    # puppy|kitten|adult|senior|pregnant|lactating
      t.string :activity_level, null: false # sedentary|low|moderate|high|very_high
      t.integer :body_condition_score, default: 5, null: false  # 1-9 BCS scale
      t.boolean :is_neutered, default: false, null: false

      t.timestamps
    end

    add_index :pets, :species
    add_index :pets, :life_stage
  end
end
