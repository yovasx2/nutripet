class PrescriptionItem < ApplicationRecord
  belongs_to :diet_prescription
  belongs_to :ingredient

  validates :daily_amount_g, :pct_of_diet, presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :diet_prescription_id, uniqueness: { scope: :ingredient_id }
end
