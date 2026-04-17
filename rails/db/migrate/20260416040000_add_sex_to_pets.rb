class AddSexToPets < ActiveRecord::Migration[7.2]
  def change
    add_column :pets, :sex, :string, null: false, default: "female"
    add_index  :pets, :sex
  end
end
