class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :diets, through: :recipe_ingredients
  has_many :prescription_items, dependent: :restrict_with_error

  SPECIES_SAFE_VALUES  = %w[dog cat both none].freeze
  SOURCES              = %w[USDA INIFAP manual].freeze
  CATEGORIES           = %w[protein carb vegetable fat].freeze
  SAFETY_STATUSES      = %w[safe caution toxic].freeze

  validates :name,          presence: true, uniqueness: true
  validates :species_safe,  inclusion: { in: SPECIES_SAFE_VALUES }
  validates :energy_kcal,   numericality: { greater_than_or_equal_to: 0 }
  validates :category,      inclusion: { in: CATEGORIES }
  validates :safety_status, inclusion: { in: SAFETY_STATUSES }

  # Species safety
  scope :safe_for,       ->(species) { where(species_safe: [species, "both"]) }
  # Safety filter — never serve toxic ingredients
  scope :non_toxic,      -> { where.not(safety_status: "toxic") }
  scope :safe_only,      -> { where(safety_status: "safe") }
  # Category scopes
  scope :proteins,       -> { where(category: "protein") }
  scope :carbs,          -> { where(category: "carb") }
  scope :vegetables,     -> { where(category: "vegetable") }
  scope :fats,           -> { where(category: "fat") }
  # Source
  scope :catalog,        -> { where(is_custom: false) }
  scope :custom,         -> { where(is_custom: true) }
  # Raw-feeding: only ingredients confirmed safe uncooked
  scope :raw_safe,       -> { where(raw_safe: true) }
  # Therapeutic: ingredients that help a specific condition
  scope :therapeutic_for_condition, ->(condition_id) {
    where("? = ANY(therapeutic_for)", condition_id)
  }

  # Returns only safe, non-toxic ingredients available for a pet
  # (excludes allergens and condition-linked dangerous items)
  def self.permitted_for(pet)
    allergen_ingredient_names = pet.allergens.pluck(:name)
    non_toxic
      .safe_for(pet.species)
      .where.not(name: allergen_ingredient_names)
  end

  def dry_matter_protein_pct
    return 0 if moisture_g >= 100
    (protein_g / (100.0 - moisture_g)) * 100
  end

  def dry_matter_fat_pct
    return 0 if moisture_g >= 100
    (fat_g / (100.0 - moisture_g)) * 100
  end
end
