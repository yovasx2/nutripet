class RecipeContraindicatedCondition < ApplicationRecord
  belongs_to :diet
  belongs_to :condition

  validates :diet_id, uniqueness: { scope: :condition_id }
end
