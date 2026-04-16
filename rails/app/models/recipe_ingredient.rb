class RecipeIngredient < ApplicationRecord
  belongs_to :diet
  belongs_to :ingredient

  validates :base_percentage, presence: true,
            numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :diet_id, uniqueness: { scope: :ingredient_id }
end
