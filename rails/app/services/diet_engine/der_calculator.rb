# DietEngine::DerCalculator
#
# Calculates Daily Energy Requirement (DER) in kcal for a pet.
#
# Formula:
#   RER = 70 × weight_kg^0.75  (Resting Energy Requirement)
#   DER = RER × multiplier
#
# Multipliers from AAFCO/FEDIAF and NRC references.

module DietEngine
  class DerCalculator
    # [species][life_stage][activity_or_neuter_state] => multiplier
    MULTIPLIERS = {
      "dog" => {
        "puppy"     => { default: 3.0, old: 2.5 },   # old = >4 months
        "adult"     => { intact: 1.8, neutered: 1.6, sedentary: 1.4, active: 1.8, very_active: 2.0 },
        "senior"    => { default: 1.4 },
        "pregnant"  => { default: 3.0 },
        "lactating" => { default: 4.8 }
      },
      "cat" => {
        "kitten"    => { default: 2.5 },
        "adult"     => { intact: 1.4, neutered: 1.2, indoor: 1.2, outdoor: 1.4 },
        "senior"    => { default: 1.1 },
        "pregnant"  => { default: 2.0 },
        "lactating" => { default: 3.0 }
      }
    }.freeze

    # Activity level multiplier adjustments applied on top of base
    ACTIVITY_ADJUSTMENT = {
      "sedentary" => -0.2,
      "low"       => -0.1,
      "moderate"  =>  0.0,
      "high"      =>  0.2,
      "very_high" =>  0.4
    }.freeze

    def initialize(pet)
      @pet = pet
    end

    def rer
      (70 * (@pet.weight_kg.to_f**0.75)).round(2)
    end

    def multiplier
      base = base_multiplier
      adjustment = ACTIVITY_ADJUSTMENT.fetch(@pet.activity_level, 0.0)
      (base + adjustment).round(2)
    end

    def der
      (rer * multiplier).round(2)
    end

    private

    def base_multiplier
      species_table = MULTIPLIERS[@pet.species] || MULTIPLIERS["dog"]
      stage_table   = species_table[@pet.life_stage] || species_table["adult"]

      if @pet.is_neutered
        stage_table[:neutered] || stage_table[:default] || 1.6
      else
        stage_table[:intact] || stage_table[:default] || 1.8
      end
    end
  end
end
