class RecipeContraindicatedAllergen < ApplicationRecord
  belongs_to :diet
  belongs_to :allergen

  validates :diet_id, uniqueness: { scope: :allergen_id }
end
