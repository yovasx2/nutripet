class AddCategoryAndSafetyToIngredients < ActiveRecord::Migration[7.2]
  def change
    add_column :ingredients, :category,         :string,  null: false, default: "protein"
    add_column :ingredients, :safety_status,    :string,  null: false, default: "safe"
    add_column :ingredients, :safety_notes,     :text
    # therapeutic_for: array of condition IDs this ingredient helps (e.g. diarrhea, constipation)
    add_column :ingredients, :therapeutic_for,  :integer, array: true, default: []
    # raw_safe: ingredient can safely be served uncooked
    add_column :ingredients, :raw_safe,         :boolean, null: false, default: false

    add_index :ingredients, :category
    add_index :ingredients, :safety_status
    add_index :ingredients, :therapeutic_for, using: :gin
  end
end
