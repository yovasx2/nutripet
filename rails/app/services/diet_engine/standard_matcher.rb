# DietEngine::StandardMatcher
#
# Finds the best matching NutritionalStandard row for a pet's species and life stage.
# Prefers an exact life_stage match over the catch-all "all_life_stages" row.

module DietEngine
  class StandardMatcher
    def initialize(pet)
      @pet = pet
    end

    # Returns the best NutritionalStandard for the pet:
    #   1. Exact life_stage match beats 'all_life_stages' fallback
    #   2. Among ties, preferred org for species (AAFCO for dogs, FEDIAF for cats) wins
    #   3. Falls back to NRC if no AAFCO/FEDIAF row exists
    #   Pass org_name: to force a specific standard organization
    def match(org_name: nil)
      NutritionalStandard
        .for_species_and_stage(@pet.species, @pet.life_stage, org_name)
        .first
    end

    # Match against a specific organization (e.g. for comparison views)
    def match_for(org_name)
      NutritionalStandard
        .for_species_and_stage(@pet.species, @pet.life_stage, org_name)
        .first
    end

    def match!(org_name: nil)
      match(org_name: org_name) || raise("No nutritional standard found for #{@pet.species}/#{@pet.life_stage}#{org_name ? " (#{org_name})" : ""}")
    end
  end
end
