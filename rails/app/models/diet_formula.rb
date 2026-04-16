class DietFormula < ApplicationRecord
  REUSE_THRESHOLD = 2
  ACTIVITY_BUCKETS = {
    "sedentary" => "low",
    "low"       => "low",
    "moderate"  => "moderate",
    "high"      => "high",
    "very_high" => "high"
  }.freeze

  has_many :diet_prescriptions

  validates :fingerprint, presence: true, uniqueness: true
  validates :species, presence: true
  validates :life_stage, presence: true
  validates :ingredient_composition, presence: true

  scope :for_pet, ->(pet) {
    fp = generate_fingerprint(pet)
    where(fingerprint: fp)
  }

  scope :popular, -> { where("upvotes_count >= ?", REUSE_THRESHOLD).order(upvotes_count: :desc) }

  def reusable?
    upvotes_count >= REUSE_THRESHOLD
  end

  def total_daily_g(der_kcal)
    energy_density = ingredient_composition.sum do |ing_id, pct|
      ingredient = Ingredient.find_by(id: ing_id.to_i)
      next 0.0 unless ingredient
      (pct.to_f / 100.0) * ingredient.energy_kcal.to_f
    end
    return 0.0 if energy_density.zero?
    ((der_kcal.to_f / energy_density) * 100).round(1)
  end

  def self.generate_fingerprint(pet)
    activity_bucket = ACTIVITY_BUCKETS[pet.activity_level] || pet.activity_level
    condition_ids   = pet.conditions.order(:id).pluck(:id)
    allergen_ids    = pet.allergens.order(:id).pluck(:id)

    key = [
      pet.species,
      pet.life_stage,
      activity_bucket,
      condition_ids.join(","),
      allergen_ids.join(",")
    ].join("|")

    Digest::SHA1.hexdigest(key)
  end
end
