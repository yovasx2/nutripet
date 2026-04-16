class UpdateDietPrescriptionsForFormulas < ActiveRecord::Migration[7.2]
  def change
    # master_recipe is now optional (formulas don't use it)
    change_column_null :diet_prescriptions, :master_recipe_id, true

    add_reference :diet_prescriptions, :diet_formula,       null: true, foreign_key: true
    add_column    :diet_prescriptions, :upvotes_count,      :integer, null: false, default: 0

    # Diet type: homemade / commercial / mixed
    add_column    :diet_prescriptions, :diet_type,          :string, null: false, default: "homemade"
    # Preparation style (homemade/mixed only): cooked / raw / mixed
    add_column    :diet_prescriptions, :preparation_style,  :string, null: false, default: "cooked"
    # Nutritional standard override: AAFCO / FEDIAF / NRC (nil = auto-detect)
    add_column    :diet_prescriptions, :standard_override,  :string
    # Free-text notes entered by the user at prescription time
    add_column    :diet_prescriptions, :custom_allergens_notes,   :text
    add_column    :diet_prescriptions, :custom_conditions_notes,  :text
  end
end
