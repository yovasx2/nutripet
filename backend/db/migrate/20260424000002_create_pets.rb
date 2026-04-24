class CreatePets < ActiveRecord::Migration[8.1]
  def change
    create_table :pets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :breed, null: false
      t.string :sex, null: false
      t.integer :age_years, null: false, default: 0
      t.integer :age_months, null: false, default: 0
      t.decimal :weight, precision: 6, scale: 2, null: false
      t.string :activity_level, null: false, default: 'moderate'
      t.string :life_stage, null: false, default: 'adult'
      t.integer :ecc_score, null: false, default: 5
      t.string :reproductive_status, null: false, default: 'none'
      t.string :selected_kibble_id

      t.timestamps
    end
  end
end
