class Pet < ApplicationRecord
  belongs_to :user

  validates :name, :breed, :sex, :activity_level, :life_stage, :reproductive_status, presence: true
  validates :age_years, :age_months, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :ecc_score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 9 }
  validates :weight, numericality: { greater_than: 0 }
end
