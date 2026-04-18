class Premix < ApplicationRecord
  SPECIES_SAFE_VALUES = %w[dog cat both].freeze
  MICRO_KEYS = %i[
    calcium_mg
    phosphorus_mg
    magnesium_mg
    potassium_mg
    zinc_mg
    iron_mg
    copper_mg
    iodine_mcg
    selenium_mcg
  ].freeze

  validates :name, presence: true, uniqueness: true
  validates :species_safe, inclusion: { in: SPECIES_SAFE_VALUES }

  scope :active, -> { where(active: true) }
  scope :safe_for, ->(species) { where(species_safe: [species, "both"]) }

  def nutrient_per_g(key)
    public_send("#{key}_per_g").to_f
  end

  def recommendation_for(deficits)
    relevant_deficits = deficits.select { |_key, value| value.to_f.positive? }
    return nil if relevant_deficits.empty?
    return nil unless relevant_deficits.keys.all? { |key| nutrient_per_g(key).positive? }

    grams_per_day = relevant_deficits.map do |key, deficit|
      deficit.to_f / nutrient_per_g(key)
    end.max

    payload = MICRO_KEYS.each_with_object({}) do |key, hash|
      hash[key] = (nutrient_per_g(key) * grams_per_day).round(4)
    end

    overdose_score = relevant_deficits.sum do |key, deficit|
      [(payload[key].to_f - deficit.to_f), 0.0].max
    end

    {
      premix: self,
      grams_per_day: grams_per_day.round(2),
      payload: payload,
      overdose_score: overdose_score.round(4)
    }
  end

  def self.recommend_for(pet:, deficits:)
    candidates = active.safe_for(pet.species).map do |premix|
      premix.recommendation_for(deficits)
    end.compact

    candidates.min_by { |candidate| [candidate[:grams_per_day], candidate[:overdose_score], candidate[:premix].name] }
  end
end
