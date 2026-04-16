class CommercialFood < ApplicationRecord
  SPECIES       = %w[dog cat both].freeze
  LIFE_STAGES   = %w[puppy kitten adult senior pregnant lactating all_life_stages].freeze
  FOOD_FORMS    = %w[dry wet semi_moist].freeze
  LABEL_STANDARDS = %w[AAFCO FEDIAF NRC].freeze

  has_many :diet_prescriptions, dependent: :nullify

  validates :name,     presence: true, uniqueness: true
  validates :species,  presence: true, inclusion: { in: SPECIES }
  validates :food_form, inclusion: { in: FOOD_FORMS }, allow_nil: true
  validates :protein_min_pct, :fat_min_pct,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :energy_kcal_per_kg,
            numericality: { greater_than: 0 }, allow_nil: true

  scope :active,       -> { where(is_active: true) }
  scope :for_species,  ->(species) { where(species: [species, "both"]) }

  # Daily portion in grams given the pet's DER in kcal
  def daily_portion_g(der_kcal)
    return nil unless energy_kcal_per_kg.to_f > 0
    ((der_kcal.to_f / energy_kcal_per_kg.to_f) * 1000).round(1)
  end

  def form_label
    { "dry" => "Seco", "wet" => "Húmedo", "semi_moist" => "Semi-húmedo" }[food_form] || food_form.to_s.humanize
  end
end
