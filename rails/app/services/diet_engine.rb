module DietEngine
  # Calorie % distribution for energy-dense categories only (protein, carb, fat — sums to 100).
  # Vegetables are sized by weight (VEGETABLE_WEIGHT_PCT) to avoid inflated portions from
  # calorie-sparse ingredients like watercress or zucchini.
  KCAL_COMPOSITION = {
    "cooked" => { protein: 60, carb: 27, fat: 13 },
    "raw"    => { protein: 80, carb: 0,  fat: 20 },
    "mixed"  => { protein: 67, carb: 20, fat: 13 }
  }.freeze

  # Vegetable grams as % of total protein+carb+fat weight (not calorie-based)
  VEGETABLE_WEIGHT_PCT = { "cooked" => 15, "raw" => 15, "mixed" => 15 }.freeze

  # How many ingredients to pick per category
  SAMPLE_COUNT = { protein: 1, vegetable: 1, carb: 1, fat: 1 }.freeze

  # AAFCO 2023 minimums — % of Dry Matter basis
  # Source: AAFCO Dog Food Nutrient Profiles 2023
  AAFCO = {
    "adult"     => { protein_min: 18.0, fat_min: 5.5,  label: "Adulto (mantenimiento)" },
    "senior"    => { protein_min: 18.0, fat_min: 5.5,  label: "Senior (mantenimiento)" },
    "growth"    => { protein_min: 22.5, fat_min: 8.5,  label: "Crecimiento (cachorro)" },
    "gestation" => { protein_min: 22.5, fat_min: 8.5,  label: "Gestación",
                     note: "Mismo mínimo que crecimiento (AAFCO 'Growth & Reproduction')." },
    "lactation" => { protein_min: 25.0, fat_min: 8.5,  label: "Lactancia",
                     note: "La etapa de mayor demanda. Se recomienda ≥25% BMS de proteína; la ingesta total puede triplicar el mantenimiento." }
  }.freeze

  LIFE_STAGE_TO_AAFCO = {
    "puppy"     => "growth",
    "adult"     => "adult",
    "senior"    => "senior",
    "pregnant"  => "gestation",
    "lactating" => "lactation"
  }.freeze

  PREP_NOTES = {
    "cooked" => "Cocinar las proteínas y carbohidratos completamente (temp. interna ≥ 74 °C). Desinfectar las verduras antes de usarlas y cocinarlas ligeramente al vapor. No añadir sal, cebolla, ajo ni condimentos. Dividir en 2 porciones al día y servir a temperatura ambiente.",
    "raw"    => "Usar únicamente carne fresca de grado alimenticio. Descongelar en refrigerador — nunca a temperatura ambiente. Cortar en trozos adecuados al tamaño de la mascota para evitar atragantamiento. Desinfectar las verduras antes de usarlas. Mantener carne y verduras separadas de alimentos humanos en todo momento. Desinfectar utensilios, tablas de corte y lavarse las manos con agua y jabón tras la preparación.",
    "mixed"  => "Cocinar las proteínas y carbohidratos completamente antes de servir (temp. interna ≥ 74 °C). Desinfectar las verduras antes de usarlas; pueden servirse crudas o al vapor. Mantener los componentes crudos y cocidos en recipientes separados hasta el momento de servir. No añadir sal, cebolla, ajo ni condimentos. Lavar utensilios y superficies con agua y jabón tras la preparación."
  }.freeze

  class << self
    def generate(pet, preparation_style:, excluded_ingredient_ids: [])
      style = preparation_style.to_s
      style = "cooked" unless KCAL_COMPOSITION.key?(style)

      calc = DietEngine::DerCalculator.new(pet)
      der  = adjusted_der(calc.der, pet)

      pool = diet_pool(pet, style, excluded_ingredient_ids)
      items = build_items(pool, style, der)

      macros = compute_macros(items)
      aafco  = compute_aafco(pet, macros)

      {
        der_kcal:          der.round(1),
        daily_portion_g:   items.sum { |i| i[:daily_amount_g] }.round(1),
        preparation_style: style,
        items:             items,
        engine_output: {
          "macros"                 => macros,
          "aafco"                  => aafco,
          "preparation_notes"      => PREP_NOTES[style],
          "excluded_ingredient_ids" => excluded_ingredient_ids.uniq
        }
      }
    end

    # Phase 2: deterministic optimizer that builds a fixed recipe set (3-5)
    # validated under hard nutritional constraints for the aggregate set.
    def generate_fixed_set(pet, total_kcal_set: nil, diet_mode: "cooked")
      DietEngine::Optimizer
        .new(pet: pet, total_kcal_set: total_kcal_set, diet_mode: diet_mode)
        .generate_fixed_set
    end

    # Recompute macros + AAFCO from existing diet_items (after swap/remove)
    def recalculate_output(pet, diet)
      items = diet.diet_items.includes(:ingredient).map do |di|
        { ingredient: di.ingredient, daily_amount_g: di.daily_amount_g, pct_of_diet: di.pct_of_diet }
      end
      total_g = items.sum { |i| i[:daily_amount_g] }
      macros  = compute_macros(items)
      aafco   = compute_aafco(pet, macros)

      diet.update!(
        daily_portion_g: total_g.round(1),
        engine_output:   diet.engine_output.merge("macros" => macros, "aafco" => aafco)
      )
    end

    # Rescale all diet_item gram amounts to match the pet's new DER, then
    # update macros/AAFCO. Called after the pet's attributes change (weight, BCS, etc.).
    def rescale_to_pet!(pet, diet)
      return unless diet

      new_der = adjusted_der(DietEngine::DerCalculator.new(pet).der, pet)
      diet_items = diet.diet_items.includes(:ingredient).to_a
      return if diet_items.empty?

      current_kcal = diet_items.sum { |di| di.ingredient.energy_kcal.to_f * di.daily_amount_g / 100.0 }
      return if current_kcal <= 0

      scale = new_der / current_kcal

      diet.transaction do
        diet_items.each do |di|
          di.update!(daily_amount_g: (di.daily_amount_g * scale).round(1))
        end

        items  = diet_items.map { |di| { ingredient: di.ingredient, daily_amount_g: di.daily_amount_g, pct_of_diet: di.pct_of_diet } }
        macros = compute_macros(items)
        aafco  = compute_aafco(pet, macros)

        diet.update!(
          der_kcal:        new_der.round(1),
          daily_portion_g: items.sum { |i| i[:daily_amount_g] }.round(1),
          engine_output:   diet.engine_output.merge("macros" => macros, "aafco" => aafco)
        )
      end
    end

    # Generate diet from a specific list of ingredient IDs chosen by the user.
    # Protein/carb/fat are allocated by calorie %; vegetables by weight % of total.
    def generate_with_ingredients(pet, preparation_style:, ingredient_ids:, excluded_ingredient_ids: [])
      style = preparation_style.to_s
      style = "cooked" unless KCAL_COMPOSITION.key?(style)

      calc = DietEngine::DerCalculator.new(pet)
      der  = adjusted_der(calc.der, pet)

      pool         = diet_pool(pet, style, excluded_ingredient_ids)
      selected     = pool.where(id: ingredient_ids).to_a
      kcal_comp    = KCAL_COMPOSITION[style]
      kcal_cats    = %i[protein carb fat].select { |cat| kcal_comp[cat].to_i > 0 }

      return generate(pet, preparation_style: style, excluded_ingredient_ids: excluded_ingredient_ids) if selected.empty? && pool.none?

      selected_by_category = selected.group_by(&:category)
      available_kcal_cats  = kcal_cats.select do |cat|
        selected_by_category[cat.to_s].present? || pool.send("#{cat}s").exists?
      end
      effective_comp = normalized_composition(kcal_comp, available_kcal_cats)

      return generate(pet, preparation_style: style, excluded_ingredient_ids: excluded_ingredient_ids) if effective_comp.empty?

      items        = []
      selected_cats = available_kcal_cats.select { |cat| selected_by_category[cat.to_s].present? }
      refill_cats   = available_kcal_cats - selected_cats
      selected_ids  = selected.map(&:id)

      # Calorie-based items: protein, carb, fat
      selected_cats.each do |cat|
        cat_ings           = selected_by_category[cat.to_s]
        per_ingredient_pct = effective_comp[cat].to_f / cat_ings.size

        cat_ings.each do |ingredient|
          kcal_alloc = der * (per_ingredient_pct / 100.0)
          daily_g    = ingredient.energy_kcal > 0 ? (kcal_alloc / ingredient.energy_kcal * 100.0) : 0
          items << { ingredient: ingredient, pct_of_diet: per_ingredient_pct.round(2), daily_amount_g: daily_g.round(1) }
        end
      end

      refill_cats.each do |cat|
        candidates = pool.send("#{cat}s").where.not(id: selected_ids).to_a
        next if candidates.empty?

        chosen             = candidates.sample([SAMPLE_COUNT[cat], candidates.size].min)
        per_ingredient_pct = effective_comp[cat].to_f / chosen.size

        chosen.each do |ingredient|
          kcal_alloc = der * (per_ingredient_pct / 100.0)
          daily_g    = ingredient.energy_kcal > 0 ? (kcal_alloc / ingredient.energy_kcal * 100.0) : 0
          items << { ingredient: ingredient, pct_of_diet: per_ingredient_pct.round(2), daily_amount_g: daily_g.round(1) }
        end
      end

      return generate(pet, preparation_style: style, excluded_ingredient_ids: excluded_ingredient_ids) if items.empty?

      # Vegetable items: weight % of calorie-item total
      veg_pct = VEGETABLE_WEIGHT_PCT[style].to_f
      if veg_pct > 0
        veg_target_g    = items.sum { |i| i[:daily_amount_g] } * veg_pct / 100.0
        user_vegs       = selected_by_category["vegetable"] || []
        veg_ingredients = if user_vegs.any?
          user_vegs
        else
          cands = pool.vegetables.where.not(id: selected_ids).to_a
          cands.empty? ? [] : cands.sample([SAMPLE_COUNT[:vegetable], cands.size].min)
        end

        unless veg_ingredients.empty?
          per_veg_g = veg_target_g / veg_ingredients.size
          veg_ingredients.each do |ingredient|
            items << { ingredient: ingredient, pct_of_diet: 0.0, daily_amount_g: per_veg_g.round(1) }
          end
        end
      end

      # Normalize all grams so total delivered kcal == DER exactly.
      total_kcal = items.sum { |i| i[:ingredient].energy_kcal.to_f * i[:daily_amount_g] / 100.0 }
      if total_kcal > 0
        scale = der / total_kcal
        items.each { |i| i[:daily_amount_g] = (i[:daily_amount_g] * scale).round(1) }
      end

      macros = compute_macros(items)
      aafco  = compute_aafco(pet, macros)

      {
        der_kcal:          der.round(1),
        daily_portion_g:   items.sum { |i| i[:daily_amount_g] }.round(1),
        preparation_style: style,
        items:             items,
        engine_output: {
          "macros"                  => macros,
          "aafco"                   => aafco,
          "preparation_notes"       => PREP_NOTES[style],
          "excluded_ingredient_ids" => excluded_ingredient_ids.uniq
        }
      }
    end

    # Compute macros live from current diet_items (for show action, no DB write)
    def live_macros(diet)
      items = diet.diet_items.includes(:ingredient).map do |di|
        { ingredient: di.ingredient, daily_amount_g: di.daily_amount_g, pct_of_diet: di.pct_of_diet }
      end
      compute_macros(items)
    end

    # Compute AAFCO live (for show action, no DB write)
    def live_aafco(pet, macros)
      compute_aafco(pet, macros)
    end

    # Alternatives for a given diet_item (same category, safe for pet, not already in diet)
    def alternatives_for(pet, diet, diet_item)
      current_ids = diet.diet_items.pluck(:ingredient_id)
      category    = diet_item.ingredient.category
      pool        = Ingredient.non_toxic.safe_for(pet.species)
      pool        = pool.raw_safe if diet.preparation_style == "raw"
      pool.send("#{category}s").where.not(id: current_ids).order(:name)
    end

    def adjusted_der(der, pet)
      bcs = pet.body_condition_score.to_i
      return der if bcs == 5

      # Adjust DER by 5% per BCS point away from ideal (5), using current weight as base.
      # This avoids the aggressive swings of IBW-based calculation:
      #   - Overweight (BCS 6-9): modest caloric restriction (-5% to -20%)
      #   - Underweight (BCS 1-4): modest caloric surplus (+5% to +20%)
      # Source: WSAVA / WSAVA Global Nutrition Committee practical guidelines.
      bcs_delta  = bcs - 5
      adjustment = bcs_delta * -0.05   # negative for overweight, positive for underweight
      (der * (1.0 + adjustment)).round(2)
    end

    def diet_pool(pet, style, excluded_ingredient_ids)
      pool = Ingredient.non_toxic.safe_for(pet.species)
      pool = pool.raw_safe if style == "raw"
      excluded_ingredient_ids.any? ? pool.where.not(id: excluded_ingredient_ids) : pool
    end

    def normalized_composition(base_comp, categories)
      total_pct = categories.sum { |cat| base_comp[cat] }
      return {} if total_pct.zero?

      scale = 100.0 / total_pct
      categories.each_with_object({}) do |cat, hash|
        hash[cat] = (base_comp[cat].to_f * scale).round(2)
      end
    end

    private

    def build_items(pool, style, der)
      comp   = KCAL_COMPOSITION[style]
      counts = SAMPLE_COUNT
      items  = []

      # Step 1: protein, carb, fat — allocated by calorie %
      %i[protein carb fat].each do |cat|
        pct = comp[cat]
        next if pct.nil? || pct.zero?

        candidates = pool.send("#{cat}s").to_a
        next if candidates.empty?

        selected           = candidates.sample([counts[cat], candidates.size].min)
        per_ingredient_pct = pct.to_f / selected.size

        selected.each do |ingredient|
          kcal_alloc = der * (per_ingredient_pct / 100.0)
          daily_g    = ingredient.energy_kcal > 0 ? (kcal_alloc / ingredient.energy_kcal * 100.0) : 0
          items << { ingredient: ingredient, pct_of_diet: per_ingredient_pct.round(2), daily_amount_g: daily_g.round(1) }
        end
      end

      # Step 2: vegetables — weight % of macro-item total
      # This prevents calorie-sparse vegetables from producing unrealistic gram amounts
      veg_pct = VEGETABLE_WEIGHT_PCT[style].to_f
      if veg_pct > 0
        kcal_total_g = items.sum { |i| i[:daily_amount_g] }
        veg_target_g = kcal_total_g * veg_pct / 100.0
        candidates   = pool.vegetables.to_a

        unless candidates.empty?
          chosen    = candidates.sample([counts[:vegetable], candidates.size].min)
          per_veg_g = veg_target_g / chosen.size
          chosen.each do |ingredient|
            items << { ingredient: ingredient, pct_of_diet: 0.0, daily_amount_g: per_veg_g.round(1) }
          end
        end
      end

      # Step 3: normalize all grams so total delivered kcal == DER exactly.
      # Vegetables are calorie-additive on top of the macro budget without this step.
      total_kcal = items.sum { |i| i[:ingredient].energy_kcal.to_f * i[:daily_amount_g] / 100.0 }
      if total_kcal > 0
        scale = der / total_kcal
        items.each { |i| i[:daily_amount_g] = (i[:daily_amount_g] * scale).round(1) }
      end

      items
    end

    def compute_aafco(pet, macros)
      stage_key = LIFE_STAGE_TO_AAFCO[pet.life_stage] || "adult"
      standard  = AAFCO[stage_key]

      moisture   = macros["moisture_g"].to_f
      total      = macros["total_g"].to_f
      dry_matter = total - moisture
      return {} if dry_matter <= 0

      protein_pct_dm = (macros["protein_g"].to_f / dry_matter * 100).round(1)
      fat_pct_dm     = (macros["fat_g"].to_f     / dry_matter * 100).round(1)

      {
        "standard"         => "AAFCO 2023",
        "life_stage_group" => standard[:label],
        "protein_min_pct"  => standard[:protein_min],
        "fat_min_pct"      => standard[:fat_min],
        "protein_pct_dm"   => protein_pct_dm,
        "fat_pct_dm"       => fat_pct_dm,
        "protein_ok"       => protein_pct_dm >= standard[:protein_min],
        "fat_ok"           => fat_pct_dm     >= standard[:fat_min],
        "note"             => standard[:note]
      }
    end

    def compute_macros(items)
      total_g = items.sum { |i| i[:daily_amount_g] }
      return {} if total_g.zero?

      protein_g = items.sum { |i| i[:ingredient].protein_g * i[:daily_amount_g] / 100.0 }
      fat_g     = items.sum { |i| i[:ingredient].fat_g     * i[:daily_amount_g] / 100.0 }
      carbs_g   = items.sum { |i| i[:ingredient].carbs_g   * i[:daily_amount_g] / 100.0 }
      moisture_g = items.sum { |i| i[:ingredient].moisture_g * i[:daily_amount_g] / 100.0 }

      {
        "protein_g"  => protein_g.to_f.round(1),
        "fat_g"      => fat_g.to_f.round(1),
        "carbs_g"    => carbs_g.to_f.round(1),
        "moisture_g" => moisture_g.to_f.round(1),
        "total_g"    => total_g.to_f.round(1)
      }
    end
  end
end
