class PetCondition < ApplicationRecord
  belongs_to :pet
  belongs_to :condition

  validates :pet_id, uniqueness: { scope: :condition_id }
end
