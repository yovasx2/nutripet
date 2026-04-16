class Diet < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  has_many :recipe_contraindicated_conditions, dependent: :destroy
  has_many :contraindicated_conditions, through: :recipe_contraindicated_conditions, source: :condition

  has_many :recipe_contraindicated_allergens, dependent: :destroy
  has_many :contraindicated_allergens, through: :recipe_contraindicated_allergens, source: :allergen

  has_many :diet_prescriptions, dependent: :restrict_with_error

  STATUSES = %w[draft active archived].freeze
  SPECIES = %w[dog cat].freeze
  LIFE_STAGES = (Pet::LIFE_STAGES + ["all_life_stages"]).freeze

  validates :name, presence: true, uniqueness: true
  validates :species, presence: true, inclusion: { in: SPECIES }
  validates :life_stage, presence: true, inclusion: { in: LIFE_STAGES }
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }
  scope :for_species, ->(species) { where(species: species) }
  scope :for_life_stage, ->(stage) {
    where("life_stage = ? OR life_stage = 'all_life_stages'", stage)
  }

  def safe_for_pet?(pet)
    pet_condition_ids = pet.conditions.pluck(:id)
    pet_allergen_ids  = pet.allergens.pluck(:id)

    return false if contraindicated_conditions.where(id: pet_condition_ids).exists?
    return false if contraindicated_allergens.where(id: pet_allergen_ids).exists?

    true
  end
end
