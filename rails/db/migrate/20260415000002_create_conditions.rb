class CreateConditions < ActiveRecord::Migration[7.2]
  def change
    create_table :conditions do |t|
      t.string :name, null: false
      t.text :description
      t.text :dietary_notes
      t.string :species_scope, default: "both", null: false  # dog | cat | both

      t.timestamps
    end

    add_index :conditions, :name, unique: true
    add_index :conditions, :species_scope
  end
end
