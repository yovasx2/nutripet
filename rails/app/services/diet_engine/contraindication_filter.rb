# DietEngine::ContraindicationFilter
#
# Filters MasterRecipe candidates, returning only recipes that are safe
# for the pet given its conditions and allergens.
# Rejected recipes are tracked with reasons for the audit trail.

module DietEngine
  class ContraindicationFilter
    attr_reader :rejected

    def initialize(pet)
      @pet      = pet
      @rejected = []
    end

    def filter(recipes)
      condition_ids = @pet.conditions.pluck(:id)
      allergen_ids  = @pet.allergens.pluck(:id)

      recipes.select do |recipe|
        safe = true

        if condition_ids.any?
          bad_conditions = recipe.contraindicated_conditions.where(id: condition_ids)
          if bad_conditions.exists?
            @rejected << {
              recipe_id:   recipe.id,
              recipe_name: recipe.name,
              reason:      "contraindicated by conditions: #{bad_conditions.pluck(:name).join(', ')}"
            }
            safe = false
          end
        end

        if allergen_ids.any? && safe
          bad_allergens = recipe.contraindicated_allergens.where(id: allergen_ids)
          if bad_allergens.exists?
            @rejected << {
              recipe_id:   recipe.id,
              recipe_name: recipe.name,
              reason:      "contraindicated by allergens: #{bad_allergens.pluck(:name).join(', ')}"
            }
            safe = false
          end
        end

        safe
      end
    end
  end
end
