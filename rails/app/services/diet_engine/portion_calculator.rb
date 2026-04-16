# DietEngine::PortionCalculator
#
# Given a MasterRecipe, a DER target (kcal), and the standard's macro bounds,
# computes per-ingredient daily amounts in grams.
#
# Algorithm:
#   1. Start from each ingredient's base_percentage in the recipe.
#   2. Sum energy per 100g weighted by percentages to get recipe energy density.
#   3. Scale total daily portion to meet DER.
#   4. Distribute grams to each ingredient proportionally.

module DietEngine
  class PortionCalculator
    attr_reader :items, :daily_portion_g

    def initialize(recipe, der_kcal)
      @recipe   = recipe
      @der_kcal = der_kcal.to_f
      @items    = []
    end

    def calculate
      recipe_ingredients = @recipe.recipe_ingredients.includes(:ingredient)
      return self if recipe_ingredients.empty?

      # Energy density of the recipe (kcal per 100g as-fed)
      energy_per_100g = recipe_ingredients.sum do |ri|
        (ri.base_percentage / 100.0) * ri.ingredient.energy_kcal
      end

      # Avoid division by zero
      energy_per_100g = energy_per_100g.positive? ? energy_per_100g : 1.0

      # Total daily portion in grams to meet DER
      @daily_portion_g = ((@der_kcal / energy_per_100g) * 100).round(1)

      # Per-ingredient amounts
      @items = recipe_ingredients.map do |ri|
        amount_g = (@daily_portion_g * ri.base_percentage / 100.0).round(1)
        {
          ingredient_id:  ri.ingredient_id,
          ingredient:     ri.ingredient,
          pct_of_diet:    ri.base_percentage,
          daily_amount_g: amount_g,
          is_substitute:  false
        }
      end

      self
    end

    def macro_summary
      totals = { protein_g: 0, fat_g: 0, carbs_g: 0, fiber_g: 0, energy_kcal: 0 }

      @items.each do |item|
        ing    = item[:ingredient]
        factor = item[:daily_amount_g] / 100.0
        totals[:protein_g]  += ing.protein_g * factor
        totals[:fat_g]      += ing.fat_g * factor
        totals[:carbs_g]    += ing.carbs_g * factor
        totals[:fiber_g]    += ing.fiber_g * factor
        totals[:energy_kcal]+= ing.energy_kcal * factor
      end

      totals.transform_values { |v| v.round(2) }
    end
  end
end
