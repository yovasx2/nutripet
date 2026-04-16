# DietEngine::FormulaPortionCalculator
#
# Like PortionCalculator but takes a composition array instead of a MasterRecipe.
# Input: array of [Ingredient, percentage] pairs summing to 100.

module DietEngine
  class FormulaPortionCalculator
    attr_reader :items, :daily_portion_g

    def initialize(composition, der_kcal)
      @composition = composition  # [[Ingredient, pct], ...]
      @der_kcal    = der_kcal.to_f
      @items       = []
    end

    def calculate
      return self if @composition.empty?

      energy_per_100g = @composition.sum do |(ingredient, pct)|
        (pct.to_f / 100.0) * ingredient.energy_kcal.to_f
      end
      energy_per_100g = energy_per_100g.positive? ? energy_per_100g : 1.0

      @daily_portion_g = ((@der_kcal / energy_per_100g) * 100).round(1)

      @items = @composition.map do |(ingredient, pct)|
        amount_g = (@daily_portion_g * pct.to_f / 100.0).round(1)
        {
          ingredient_id:  ingredient.id,
          ingredient:     ingredient,
          pct_of_diet:    pct.to_f,
          daily_amount_g: amount_g,
          is_substitute:  false
        }
      end

      self
    end

    def macro_summary
      totals = { protein_g: 0.0, fat_g: 0.0, carbs_g: 0.0, fiber_g: 0.0, energy_kcal: 0.0 }

      @items.each do |item|
        ing    = item[:ingredient]
        factor = item[:daily_amount_g].to_f / 100.0
        totals[:protein_g]  += ing.protein_g.to_f  * factor
        totals[:fat_g]      += ing.fat_g.to_f       * factor
        totals[:carbs_g]    += ing.carbs_g.to_f     * factor
        totals[:fiber_g]    += ing.fiber_g.to_f     * factor
        totals[:energy_kcal]+= ing.energy_kcal.to_f * factor
      end

      totals.transform_values { |v| v.round(2) }
    end
  end
end
