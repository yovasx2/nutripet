class Allergen < ApplicationRecord
  has_many :pet_allergens, dependent: :destroy
  has_many :pets, through: :pet_allergens

  has_many :recipe_contraindicated_allergens, dependent: :destroy
  has_many :contraindicated_recipes, through: :recipe_contraindicated_allergens, source: :diet

  CATEGORIES = %w[protein grain vegetable other].freeze

  validates :name, presence: true, uniqueness: true
  validates :category, inclusion: { in: CATEGORIES }

  scope :by_category, ->(cat) { where(category: cat) }
end
