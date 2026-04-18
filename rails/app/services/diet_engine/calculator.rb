module DietEngine
  class Calculator
    MICRO_KEYS = %i[
      calcium_mg
      phosphorus_mg
      magnesium_mg
      potassium_mg
      zinc_mg
      iron_mg
      copper_mg
      iodine_mcg
      selenium_mcg
    ].freeze

    DEFAULT_KCAL_COMPOSITION = {
      "cooked" => { protein: 60, carb: 27, fat: 13 },
      "raw" => { protein: 80, carb: 0, fat: 20 },
      "mixed" => { protein: 67, carb: 20, fat: 13 }
    }.freeze

    DEFAULT_VEGETABLE_WEIGHT_PCT = {
      "cooked" => 15,
      "raw" => 15,
      "mixed" => 15
    }.freeze

    def initialize(pet:, total_kcal_set:, diet_mode:)
      @pet = pet
      @total_kcal_set = total_kcal_set.to_f
      @diet_mode = diet_mode.to_s
      @composition = if DietEngine.const_defined?(:KCAL_COMPOSITION)
        DietEngine::KCAL_COMPOSITION.fetch(@diet_mode, DEFAULT_KCAL_COMPOSITION["cooked"])
      else
        DEFAULT_KCAL_COMPOSITION.fetch(@diet_mode, DEFAULT_KCAL_COMPOSITION["cooked"])
      end
      @vegetable_pct = if DietEngine.const_defined?(:VEGETABLE_WEIGHT_PCT)
        DietEngine::VEGETABLE_WEIGHT_PCT.fetch(@diet_mode, DEFAULT_VEGETABLE_WEIGHT_PCT["cooked"]).to_f
      else
        DEFAULT_VEGETABLE_WEIGHT_PCT.fetch(@diet_mode, DEFAULT_VEGETABLE_WEIGHT_PCT["cooked"]).to_f
      end
    end

    def build_recipes_from_slots(slots:, recipe_count:, macro_strategy: nil)
      recipe_kcal_target = recipe_count.positive? ? (@total_kcal_set / recipe_count) : @total_kcal_set

      (0...recipe_count).map do |recipe_idx|
        slot_map = slots
          .select { |slot| slot[:recipe_index] == recipe_idx }
          .index_by { |slot| slot[:category] }

        items = build_recipe_items(slot_map: slot_map, recipe_kcal_target: recipe_kcal_target, macro_strategy: macro_strategy)

        {
          name: "Receta #{recipe_idx + 1}",
          kcal_target: recipe_kcal_target.round(1),
          items: items,
          total_g: items.sum { |item| item[:daily_amount_g] }.round(1)
        }
      end
    end

    def metrics_for_set(recipes:, premix_payload: nil)
      totals = {
        kcal: 0.0,
        protein_g: 0.0,
        fat_g: 0.0,
        carbs_g: 0.0,
        fiber_g: 0.0,
        moisture_g: 0.0,
        total_g: 0.0,
        dry_matter_g: 0.0,
        micros: Hash.new(0.0)
      }

      recipes.each do |recipe|
        recipe[:items].each do |item|
          ingredient = item[:ingredient]
          grams = item[:daily_amount_g].to_f
          factor = grams / 100.0

          totals[:kcal] += ingredient.energy_kcal.to_f * factor
          totals[:protein_g] += ingredient.protein_g.to_f * factor
          totals[:fat_g] += ingredient.fat_g.to_f * factor
          totals[:carbs_g] += ingredient.carbs_g.to_f * factor
          totals[:fiber_g] += ingredient.fiber_g.to_f * factor
          totals[:moisture_g] += ingredient.moisture_g.to_f * factor
          totals[:total_g] += grams

          MICRO_KEYS.each do |key|
            totals[:micros][key] += ingredient.public_send(key).to_f * factor
          end
        end
      end

      totals[:dry_matter_g] = (totals[:total_g] - totals[:moisture_g]).to_f

      if premix_payload.present?
        MICRO_KEYS.each do |key|
          totals[:micros][key] += premix_payload.fetch(key, 0.0).to_f
        end
      end

      fat_kcal = totals[:fat_g] * 9.0
      totals[:fat_kcal_pct] = totals[:kcal].positive? ? (fat_kcal / totals[:kcal] * 100.0) : 0.0

      totals[:fiber_pct_dm] = if totals[:dry_matter_g].positive?
        (totals[:fiber_g] / totals[:dry_matter_g] * 100.0)
      else
        0.0
      end

      phosphorus = totals[:micros][:phosphorus_mg].to_f
      calcium = totals[:micros][:calcium_mg].to_f
      totals[:ca_p_ratio] = phosphorus.positive? ? (calcium / phosphorus) : 0.0

      totals
    end

    private

    def build_recipe_items(slot_map:, recipe_kcal_target:, macro_strategy: nil)
      composition = adjusted_composition(macro_strategy)
      vegetable_pct = adjusted_vegetable_pct(macro_strategy)
      items = []

      %i[protein carb fat].each do |category|
        pct = composition[category].to_f
        next if pct <= 0

        slot = slot_map[category]
        next unless slot

        ingredient = slot[:ingredient]
        kcal_alloc = recipe_kcal_target * (pct / 100.0)
        daily_g = ingredient.energy_kcal.to_f.positive? ? (kcal_alloc / ingredient.energy_kcal.to_f * 100.0) : 0.0

        items << {
          ingredient: ingredient,
          category: category,
          pct_of_diet: pct.round(2),
          daily_amount_g: daily_g.round(1),
          score: slot[:score].to_f
        }
      end

      vegetable_slot = slot_map[:vegetable]
      if vegetable_slot && vegetable_pct.positive?
        veg_target_g = items.sum { |item| item[:daily_amount_g] } * (vegetable_pct / 100.0)
        items << {
          ingredient: vegetable_slot[:ingredient],
          category: :vegetable,
          pct_of_diet: 0.0,
          daily_amount_g: veg_target_g.round(1),
          score: vegetable_slot[:score].to_f
        }
      end

      normalize_to_kcal_target!(items, recipe_kcal_target)
      items
    end

    def adjusted_composition(macro_strategy)
      return @composition if macro_strategy.blank?

      fat_delta = macro_strategy.fetch(:fat_delta_pct_points, 0.0).to_f
      protein_shift = macro_strategy.fetch(:protein_to_carb_shift_pct_points, 0.0).to_f
      adjusted = @composition.transform_values(&:to_f).dup

      return adjusted if fat_delta.zero?

      original_fat = adjusted[:fat].to_f
      new_fat = (original_fat + fat_delta).clamp(0.0, 100.0)
      shift = original_fat - new_fat
      adjusted[:fat] = new_fat

      if adjusted[:carb].to_f.positive?
        adjusted[:carb] = adjusted[:carb].to_f + shift
      else
        adjusted[:protein] = adjusted[:protein].to_f + shift
      end

      if protein_shift.positive? && adjusted[:carb].to_f.positive?
        transferable = [protein_shift, adjusted[:protein].to_f].min
        adjusted[:protein] = adjusted[:protein].to_f - transferable
        adjusted[:carb] = adjusted[:carb].to_f + transferable
      end

      adjusted
    end

    def adjusted_vegetable_pct(macro_strategy)
      return @vegetable_pct if macro_strategy.blank?

      delta = macro_strategy.fetch(:vegetable_pct_delta, 0.0).to_f
      (@vegetable_pct + delta).clamp(0.0, 40.0)
    end

    def normalize_to_kcal_target!(items, recipe_kcal_target)
      total_kcal = items.sum { |item| item[:ingredient].energy_kcal.to_f * item[:daily_amount_g].to_f / 100.0 }
      return if total_kcal <= 0

      scale = recipe_kcal_target / total_kcal
      items.each do |item|
        item[:daily_amount_g] = (item[:daily_amount_g].to_f * scale).round(1)
      end
    end
  end
end
