class PetAllergen < ApplicationRecord
  belongs_to :pet
  belongs_to :allergen

  validates :pet_id, uniqueness: { scope: :allergen_id }
end
