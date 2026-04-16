class NutritionalStandard < ApplicationRecord
  has_many :diet_prescriptions, dependent: :restrict_with_error

  STANDARD_NAMES = %w[AAFCO FEDIAF NRC].freeze
  # Preferred regulatory body per species (used by StandardMatcher)
  PREFERRED_BY_SPECIES = { "dog" => "AAFCO", "cat" => "FEDIAF" }.freeze
  SPECIES = %w[dog cat].freeze

  validates :standard_name, presence: true, inclusion: { in: STANDARD_NAMES }
  validates :species, presence: true, inclusion: { in: SPECIES }
  validates :life_stage, presence: true
  validates :protein_min_pct, :fat_min_pct, numericality: { greater_than: 0 }, allow_nil: true

  scope :for_species_and_stage, ->(species, life_stage, preferred_org = nil) {
    preferred_org ||= PREFERRED_BY_SPECIES[species.to_s] || "AAFCO"
    where(species: species)
      .where("life_stage = ? OR life_stage = 'all_life_stages'", life_stage)
      .order(
        Arel.sql(
          "CASE WHEN life_stage = #{connection.quote(life_stage)} THEN 0 ELSE 1 END, " \
          "CASE WHEN standard_name = #{connection.quote(preferred_org)} THEN 0 ELSE 1 END"
        )
      )
  }
end
