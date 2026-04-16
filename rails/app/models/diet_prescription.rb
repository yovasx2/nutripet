class DietPrescription < ApplicationRecord
  belongs_to :pet
  belongs_to :nutritional_standard
  belongs_to :diet,            optional: true
  belongs_to :diet_formula,    optional: true
  belongs_to :commercial_food, optional: true

  has_many :prescription_items, dependent: :destroy
  has_many :ingredients, through: :prescription_items

  STATUSES       = %w[calculated ai_refined needs_review].freeze
  LLM_STATUSES   = %w[pending done failed].freeze
  SOURCES        = %w[engine llm_refined].freeze
  DIET_TYPES     = %w[homemade commercial mixed].freeze
  PREP_STYLES    = %w[cooked raw mixed].freeze

  validates :der_kcal, :daily_portion_g, presence: true,
            numericality: { greater_than: 0 }
  validates :status,    inclusion: { in: STATUSES }
  validates :diet_type, inclusion: { in: DIET_TYPES }, allow_nil: true
  validates :preparation_style, inclusion: { in: PREP_STYLES }, allow_nil: true

  scope :latest_for_pet, ->(pet_id) {
    where(pet_id: pet_id).order(created_at: :desc)
  }

  def llm_ran?
    llm_status.present?
  end

  def ai_refined?
    source == "llm_refined"
  end

  def display_output
    final_output.presence || engine_output
  end

  def recipe_name
    commercial_food&.name || diet_formula&.name || diet&.name || "Fórmula personalizada"
  end

  def preparation_notes
    display_output["preparation_notes"].presence ||
      diet_formula&.preparation_notes ||
      diet&.preparation_notes
  end

  def diet_type_label
    { "homemade" => "Casera", "commercial" => "Comercial", "mixed" => "Mixta" }[diet_type] || diet_type.to_s.humanize
  end

  def prep_style_label
    { "cooked" => "Cocida", "raw" => "Cruda", "mixed" => "Mixta" }[preparation_style] || preparation_style.to_s.humanize
  end
end
