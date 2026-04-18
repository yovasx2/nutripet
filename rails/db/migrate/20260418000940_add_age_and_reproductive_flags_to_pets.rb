class AddAgeAndReproductiveFlagsToPets < ActiveRecord::Migration[7.2]
  def change
    add_column :pets, :age_months, :integer
    add_column :pets, :is_pregnant,  :boolean, default: false, null: false
    add_column :pets, :is_lactating, :boolean, default: false, null: false
  end
end
