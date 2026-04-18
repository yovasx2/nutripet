module DietEngine
  class Optimizer
    DEFAULT_RECIPE_COUNT_BY_MODE = {
      "raw" => 3,
      "mixed" => 4,
      "cooked" => 5
    }.freeze

    RECIPE_COUNT_RANGE_BY_MODE = {
      "raw" => (2..4),
      "mixed" => (3..5),
      "cooked" => (4..6)
    }.freeze

    MAX_RETRIES_WITHOUT_PREMIX = 12
    SLOT_CANDIDATE_POOL_LIMIT = 120
    SLOT_NEIGHBOR_DEPTH = 8
    SLOT_TOP_CANDIDATES = 10
    SLOT_SAMPLE_STEP = 10

    MACRO_STRATEGIES = [
      { key: :default, fat_delta_pct_points: 0.0, vegetable_pct_delta: 0.0 },
      { key: :lean_1, fat_delta_pct_points: -4.0, vegetable_pct_delta: 0.0 },
      { key: :lean_2, fat_delta_pct_points: -8.0, vegetable_pct_delta: 0.0 },
      { key: :lean_3, fat_delta_pct_points: -11.0, vegetable_pct_delta: 0.0 },
      { key: :lean_max, fat_delta_pct_points: -13.0, vegetable_pct_delta: 0.0 },
      { key: :fiber_boost, fat_delta_pct_points: 0.0, vegetable_pct_delta: 8.0 },
      { key: :lean_fiber, fat_delta_pct_points: -8.0, vegetable_pct_delta: 8.0 },
      { key: :lean_fiber_max, fat_delta_pct_points: -13.0, vegetable_pct_delta: 10.0 },
      { key: :carb_shift_1, fat_delta_pct_points: -13.0, vegetable_pct_delta: 10.0, protein_to_carb_shift_pct_points: 10.0 }
    ].freeze

    attr_reader :pet, :total_kcal_set, :diet_mode

    def initialize(pet:, total_kcal_set:, diet_mode:)
      @pet = pet
      @diet_mode = sanitize_diet_mode(diet_mode)
      @recipe_count = DEFAULT_RECIPE_COUNT_BY_MODE.fetch(@diet_mode, 4)
      @total_kcal_set = total_kcal_set.to_f.positive? ? total_kcal_set.to_f : default_total_kcal_set
      @selector = DietEngine::Selector.new(pet: @pet, diet_mode: @diet_mode)
      @calculator = DietEngine::Calculator.new(
        pet: @pet,
        total_kcal_set: @total_kcal_set,
        diet_mode: @diet_mode
      )
      @validator = DietEngine::Validator.new(total_kcal_set: @total_kcal_set)
    end

    def generate_fixed_set
      best_natural = nil

      candidate_recipe_counts.each do |recipe_count|
        macro_strategies.each do |macro_strategy|
          natural_result = optimize_without_premix(recipe_count: recipe_count, macro_strategy: macro_strategy)
          next unless natural_result

          if natural_result[:report]&.dig(:valid)
            return build_response(
              recipes: natural_result[:recipes],
              validation_report: natural_result[:report],
              retries_used: natural_result[:retries_used],
              premix: nil,
              mode: :natural_only,
              recipe_count: natural_result[:recipe_count],
              profile: natural_result[:profile]
            )
          end

          best_natural = natural_result if better_natural_candidate?(natural_result, best_natural)
        end
      end

      unless best_natural
        raise ArgumentError, "No hay ingredientes suficientes para construir un set fijo en ningun numero de recetas permitido"
      end

      # Closure strategy: add mandatory premix with exact deficits when natural selection cannot close gaps.
      metrics = @calculator.metrics_for_set(recipes: best_natural[:recipes])
      premix_deficits = @validator.premix_payload(metrics)
      recommendation = select_best_premix_recommendation(recipes: best_natural[:recipes], deficits: premix_deficits)
      recommendation = enforce_ca_p_ratio_with_premix(recipes: best_natural[:recipes], recommendation: recommendation) if recommendation
      premix_payload = recommendation ? recommendation[:payload] : premix_deficits
      metrics_with_premix = @calculator.metrics_for_set(recipes: best_natural[:recipes], premix_payload: premix_payload)
      report_with_premix = @validator.validate(metrics_with_premix)

      premix = {
        id: recommendation&.dig(:premix)&.id,
        name: recommendation&.dig(:premix)&.name || "Premix no disponible",
        mandatory: true,
        payload: premix_payload,
        grams_per_day: recommendation&.dig(:grams_per_day),
        description: recommendation&.dig(:premix)&.description,
        note: recommendation ? "Premix recomendado desde catálogo para cerrar déficit de micronutrientes del set" : "No hay premix registrado que cubra completamente el déficit; se muestra brecha objetivo para referencia"
      }

      build_response(
        recipes: best_natural[:recipes],
        validation_report: report_with_premix,
        retries_used: best_natural[:retries_used],
        premix: premix,
        mode: :with_premix,
        recipe_count: best_natural[:recipe_count],
        profile: best_natural[:profile]
      )
    end

    private

    def sanitize_diet_mode(diet_mode)
      mode = diet_mode.to_s
      return mode if %w[cooked raw mixed].include?(mode)

      "cooked"
    end

    def ensure_required_slots!(slots)
      required = @selector.required_categories
      missing = []

      (0...@recipe_count).each do |recipe_idx|
        required.each do |category|
          present = slots.any? { |slot| slot[:recipe_index] == recipe_idx && slot[:category] == category }
          missing << "Receta #{recipe_idx + 1} sin categoria #{category}" unless present
        end
      end

      return if missing.empty?

      raise ArgumentError, "No hay ingredientes suficientes para construir el set fijo: #{missing.join(', ')}"
    end

    def default_total_kcal_set
      der = DietEngine::DerCalculator.new(@pet).der
      adjusted = DietEngine.adjusted_der(der, @pet)
      adjusted * @recipe_count
    end

    def build_response(recipes:, validation_report:, retries_used:, premix:, mode:, recipe_count:, profile:)
      {
        fixed_set_plan: {
          recipe_count: recipe_count,
          total_kcal_set: @total_kcal_set.round(2),
          kcal_per_recipe: recipe_count.positive? ? (@total_kcal_set / recipe_count).round(2) : @total_kcal_set.round(2),
          diet_mode: @diet_mode,
          recipes: recipes,
          retries_used: retries_used,
          optimization_profile: profile,
          optimization_mode: mode.to_s,
          premix: premix,
          validation_report: validation_report
        }
      }
    end

    def candidate_recipe_counts
      range = RECIPE_COUNT_RANGE_BY_MODE.fetch(@diet_mode, 3..5)
      ([
        @recipe_count,
        @recipe_count - 1,
        @recipe_count + 1,
        range.begin,
        range.end
      ].uniq).select { |count| range.cover?(count) }
    end

    def optimize_without_premix(recipe_count:, macro_strategy:)
      slots = @selector.build_slots(recipe_count: recipe_count)
      ensure_required_slots!(slots)

      attempt = 0
      report = nil
      recipes = []

      while attempt < MAX_RETRIES_WITHOUT_PREMIX
        recipes = @calculator.build_recipes_from_slots(slots: slots, recipe_count: recipe_count, macro_strategy: macro_strategy)
        metrics = @calculator.metrics_for_set(recipes: recipes)
        report = @validator.validate(metrics)
        break if report[:valid]

        moved = improve_slots_for_constraints!(slots: slots, recipe_count: recipe_count, current_report: report)
        moved ||= @selector.rotate_lowest_scored_slot!(slots)
        break unless moved

        attempt += 1
      end

      {
        recipe_count: recipe_count,
        profile: macro_strategy[:key].to_s,
        recipes: recipes,
        report: report,
        retries_used: attempt
      }
    rescue ArgumentError
      nil
    end

    def better_natural_candidate?(candidate, current_best)
      return true if current_best.nil?

      candidate_penalty = report_penalty(candidate[:report])
      current_penalty = report_penalty(current_best[:report])
      return true if candidate_penalty < current_penalty
      return false if candidate_penalty > current_penalty

      candidate_retries = candidate[:retries_used].to_i
      current_retries = current_best[:retries_used].to_i
      return true if candidate_retries < current_retries
      return false if candidate_retries > current_retries

      candidate[:recipe_count].to_i == @recipe_count
    end

    def improve_slots_for_constraints!(slots:, recipe_count:, current_report:)
      current_penalty = report_penalty(current_report)
      best_move = nil

      slots.each do |slot|
        list = @selector.master_list(slot[:category]).limit(SLOT_CANDIDATE_POOL_LIMIT).to_a
        next if list.empty?

        candidate_positions(slot[:position].to_i, list.length).each do |next_position|
          next if next_position == slot[:position].to_i

          next_ingredient = list[next_position]
          next if next_ingredient.nil?

          previous_position = slot[:position]
          previous_ingredient = slot[:ingredient]
          previous_score = slot[:score]

          slot[:position] = next_position
          slot[:ingredient] = next_ingredient
          slot[:score] = next_ingredient.respond_to?(:score) ? next_ingredient.score.to_f : 0.0

          recipes = @calculator.build_recipes_from_slots(slots: slots, recipe_count: recipe_count)
          metrics = @calculator.metrics_for_set(recipes: recipes)
          report = @validator.validate(metrics)
          penalty = report_penalty(report)

          if penalty < current_penalty && (best_move.nil? || penalty < best_move[:penalty])
            best_move = {
              slot: slot,
              position: next_position,
              ingredient: next_ingredient,
              score: slot[:score],
              penalty: penalty
            }
          end

          slot[:position] = previous_position
          slot[:ingredient] = previous_ingredient
          slot[:score] = previous_score
        end
      end

      return false unless best_move

      slot = best_move[:slot]
      slot[:position] = best_move[:position]
      slot[:ingredient] = best_move[:ingredient]
      slot[:score] = best_move[:score]
      true
    end

    def report_penalty(report)
      return Float::INFINITY unless report

      metrics = report[:metrics] || {}
      fat_excess = [metrics.fetch(:fat_kcal_pct, 0.0).to_f - DietEngine::Validator::FAT_KCAL_MAX_PCT, 0.0].max
      fiber = metrics.fetch(:fiber_pct_dm, 0.0).to_f
      fiber_low = [DietEngine::Validator::FIBER_DM_MIN_PCT - fiber, 0.0].max
      fiber_high = [fiber - DietEngine::Validator::FIBER_DM_MAX_PCT, 0.0].max
      ratio = metrics.fetch(:ca_p_ratio, 0.0).to_f
      ratio_low = [DietEngine::Validator::CA_P_MIN_RATIO - ratio, 0.0].max
      ratio_high = [ratio - DietEngine::Validator::CA_P_MAX_RATIO, 0.0].max
      failures = Array(report[:failures]).length

      (failures * 100.0) + (fat_excess * 10.0) + ((fiber_low + fiber_high) * 20.0) + ((ratio_low + ratio_high) * 50.0)
    end

    def candidate_positions(current_position, length)
      return [] if length <= 1

      top_positions = (0...[SLOT_TOP_CANDIDATES, length].min).to_a
      forward = ((current_position + 1)..(current_position + SLOT_NEIGHBOR_DEPTH)).to_a
      backward = ((current_position - SLOT_NEIGHBOR_DEPTH)..(current_position - 1)).to_a
      sampled = (0...length).step(SLOT_SAMPLE_STEP).to_a

      (top_positions + forward + backward + sampled)
        .select { |pos| pos.between?(0, length - 1) }
        .uniq
    end

    def select_best_premix_recommendation(recipes:, deficits:)
      candidates = Premix.active.safe_for(@pet.species).map do |premix|
        recommendation = premix.recommendation_for(deficits)
        next unless recommendation

        metrics = @calculator.metrics_for_set(recipes: recipes, premix_payload: recommendation[:payload])
        report = @validator.validate(metrics)
        recommendation.merge(report: report, penalty: report_penalty(report))
      end.compact

      candidates.min_by do |candidate|
        [
          candidate.dig(:report, :valid) ? 0 : 1,
          candidate[:penalty].to_f,
          Array(candidate.dig(:report, :failures)).length,
          candidate[:grams_per_day].to_f,
          candidate[:overdose_score].to_f,
          candidate[:premix]&.name.to_s
        ]
      end
    end

    def enforce_ca_p_ratio_with_premix(recipes:, recommendation:)
      premix = recommendation[:premix]
      grams = recommendation[:grams_per_day].to_f
      return recommendation if premix.nil? || grams <= 0

      ca_per_g = premix.nutrient_per_g(:calcium_mg).to_f
      p_per_g = premix.nutrient_per_g(:phosphorus_mg).to_f
      return recommendation unless ca_per_g.positive? && p_per_g.positive?

      metrics = @calculator.metrics_for_set(recipes: recipes, premix_payload: recommendation[:payload])
      ratio = metrics[:ca_p_ratio].to_f
      return recommendation if ratio >= DietEngine::Validator::CA_P_MIN_RATIO

      base_metrics = @calculator.metrics_for_set(recipes: recipes)
      calcium_base = base_metrics.dig(:micros, :calcium_mg).to_f
      phosphorus_base = base_metrics.dig(:micros, :phosphorus_mg).to_f
      min_ratio = DietEngine::Validator::CA_P_MIN_RATIO.to_f
      denominator = (ca_per_g - (min_ratio * p_per_g))
      return recommendation unless denominator.positive?

      required_grams = ((min_ratio * phosphorus_base) - calcium_base) / denominator
      return recommendation unless required_grams.finite? && required_grams > grams

      adjusted_payload = Premix::MICRO_KEYS.each_with_object({}) do |key, payload|
        payload[key] = (premix.nutrient_per_g(key) * required_grams).round(4)
      end

      recommendation.merge(
        grams_per_day: required_grams.round(2),
        payload: adjusted_payload
      )
    end

    def macro_strategies
      strategies = MACRO_STRATEGIES.dup
      return strategies unless @diet_mode == "raw"

      strategies.reject { |strategy| strategy[:key] == :fiber_boost || strategy[:key] == :lean_fiber }
    end
  end
end
