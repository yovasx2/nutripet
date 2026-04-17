class Pet < ApplicationRecord
  belongs_to :user

  has_many :diets, dependent: :destroy

  SPECIES = %w[dog].freeze
  LIFE_STAGES = %w[puppy adult senior pregnant lactating].freeze
  ACTIVITY_LEVELS = %w[sedentary low moderate high very_high].freeze
  SEXES = %w[female male].freeze

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }
  validates :weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :life_stage, presence: true, inclusion: { in: LIFE_STAGES }
  validates :activity_level, presence: true, inclusion: { in: ACTIVITY_LEVELS }
  validates :body_condition_score, inclusion: { in: 1..9 }
  validates :sex, presence: true, inclusion: { in: SEXES }

  validate :life_stage_matches_species

  def dog?
    species == "dog"
  end

  def cat?
    species == "cat"
  end

  def female?
    sex == "female"
  end

  def male?
    sex == "male"
  end

  LIFE_STAGE_LABELS = {
    "puppy"     => "Cachorro",
    "adult"     => "Adulto",
    "senior"    => "Senior",
    "pregnant"  => "Gestante",
    "lactating" => "Lactante"
  }.freeze

  SPECIES_LABELS = {
    "dog" => "Perro"
  }.freeze

  SEX_LABELS = {
    "female" => "Hembra",
    "male"   => "Macho"
  }.freeze

  ACTIVITY_LABELS = {
    "sedentary" => "Sedentario",
    "low"       => "Bajo",
    "moderate"  => "Moderado",
    "high"      => "Alto",
    "very_high" => "Muy alto"
  }.freeze

  def species_label
    SPECIES_LABELS[species] || species.to_s.capitalize
  end

  def life_stage_label
    LIFE_STAGE_LABELS[life_stage] || life_stage.to_s.capitalize
  end

  def activity_label
    ACTIVITY_LABELS[activity_level] || activity_level.to_s.humanize
  end

  def sex_label
    SEX_LABELS[sex] || sex.to_s.capitalize
  end

  private

  def life_stage_matches_species
    if male? && life_stage.in?(%w[pregnant lactating])
      errors.add(:life_stage, "solo disponible para hembras")
    end
  end
end
