class DietItem < ApplicationRecord
  belongs_to :diet
  belongs_to :ingredient

  scope :by_weight, -> { order(daily_amount_g: :desc) }
end
