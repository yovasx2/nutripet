class Pet < ApplicationRecord
  belongs_to :user

  has_many :diets, dependent: :destroy

  SPECIES = %w[dog].freeze
  LIFE_STAGES = %w[puppy adult senior pregnant lactating].freeze
  ACTIVITY_LEVELS = %w[sedentary low moderate high very_high].freeze
  SEXES = %w[female male].freeze

  # Life stage is computed automatically from age_months + reproductive flags.
  # Senior onset is weight-dependent per AAHA 2023 Senior Care Guidelines:
  #   < 10 kg  → senior at 96 months (8 yrs) — small/toy breeds
  #   10–25 kg → senior at 84 months (7 yrs) — medium breeds
  #   25–45 kg → senior at 72 months (6 yrs) — large breeds
  #   > 45 kg  → senior at 60 months (5 yrs) — giant breeds
  # Puppy: < 12 months (AAFCO/FEDIAF standard).
  # Note: AAFCO has no separate "geriatric" nutrient profile; senior covers all older dogs.
  # is_lactating and is_pregnant override age-based stage (females only).
  before_save :compute_life_stage

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }
  validates :weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :age_months, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :activity_level, presence: true, inclusion: { in: ACTIVITY_LEVELS }
  validates :body_condition_score, presence: true, inclusion: { in: 1..9 }
  validates :sex, presence: true, inclusion: { in: SEXES }

  validate :reproductive_flags_only_for_females

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

  def compute_life_stage
    self.life_stage = if female? && is_lactating?
      "lactating"
    elsif female? && is_pregnant?
      "pregnant"
    elsif age_months.to_i < 12
      "puppy"
    elsif age_months.to_i >= senior_onset_months
      "senior"
    else
      "adult"
    end
  end

  def senior_onset_months
    kg = weight_kg.to_f
    if    kg < 10  then 96
    elsif kg < 25  then 84
    elsif kg <= 45 then 72
    else                60
    end
  end

  def reproductive_flags_only_for_females
    if male? && (is_pregnant? || is_lactating?)
      errors.add(:base, "Las opciones de gestación/lactancia solo aplican a hembras")
    end
  end
end
