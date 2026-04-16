class Pet < ApplicationRecord
  belongs_to :user

  has_many :pet_conditions, dependent: :destroy
  has_many :conditions, through: :pet_conditions

  has_many :pet_allergens, dependent: :destroy
  has_many :allergens, through: :pet_allergens

  has_many :diet_prescriptions, dependent: :destroy

  SPECIES = %w[dog cat].freeze
  LIFE_STAGES = %w[puppy kitten adult senior pregnant lactating].freeze
  ACTIVITY_LEVELS = %w[sedentary low moderate high very_high].freeze

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }
  validates :weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :life_stage, presence: true, inclusion: { in: LIFE_STAGES }
  validates :activity_level, presence: true, inclusion: { in: ACTIVITY_LEVELS }
  validates :body_condition_score, inclusion: { in: 1..9 }

  validate :life_stage_matches_species

  def dog?
    species == "dog"
  end

  def cat?
    species == "cat"
  end

  def has_conditions?
    conditions.any?
  end

  def has_allergens?
    allergens.any?
  end

  def needs_ai_refinement?
    has_conditions? || has_allergens?
  end

  private

  def life_stage_matches_species
    if dog? && life_stage == "kitten"
      errors.add(:life_stage, "cannot be kitten for a dog")
    elsif cat? && life_stage == "puppy"
      errors.add(:life_stage, "cannot be puppy for a cat")
    end
  end
end
