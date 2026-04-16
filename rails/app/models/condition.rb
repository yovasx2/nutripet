class Condition < ApplicationRecord
  has_many :pet_conditions, dependent: :destroy
  has_many :pets, through: :pet_conditions

  has_many :recipe_contraindicated_conditions, dependent: :destroy
  has_many :contraindicated_recipes, through: :recipe_contraindicated_conditions, source: :diet

  SPECIES_SCOPES = %w[dog cat both].freeze

  validates :name, presence: true, uniqueness: true
  validates :species_scope, inclusion: { in: SPECIES_SCOPES }

  scope :for_species, ->(species) { where(species_scope: [species, "both"]) }
end
