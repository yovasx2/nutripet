# DietEngine
#
# Entry points:
#
#   DietEngine.proposals(pet, options = {})
#     options: standard_name:, diet_type:, preparation_style:
#     → Returns up to 3 proposal objects for the pet.
#       diet_type "commercial" returns CommercialFood records as proposals.
#       diet_type "homemade"/"mixed" uses DietComposer (default).
#
#   DietEngine.prescribe(pet, formula_or_food, options = {})
#     → Calculates portions and persists DietPrescription + PrescriptionItems.
#
#   DietEngine.generate(pet, options = {})  [legacy / kept for DietRegenerationJob]
#     → Legacy single-pass generate using Diet catalog.

module DietEngine
  class << self
    # ------------------------------------------------------------------
    # Proposals flow
    # ------------------------------------------------------------------

    def proposals(pet, options = {})
      standard_name    = options[:standard_name].presence
      diet_type        = options[:diet_type].presence || "homemade"
      preparation_style = options[:preparation_style].presence || "cooked"

      standard = StandardMatcher.new(pet).match!(org_name: standard_name)

      # Commercial diet: return active commercial foods for the species
      if diet_type == "commercial"
        foods = CommercialFood.active.for_species(pet.species).order(:name).limit(6)
        return foods.map { |food| commercial_food_to_proposal(food, pet) }
      end

      # Homemade / Mixed: check cache then compose
      fingerprint    = DietFormula.generate_fingerprint(pet)
      cached_popular = DietFormula.where(fingerprint: fingerprint).popular.to_a

      if cached_popular.any? && diet_type == "homemade" && preparation_style == "cooked"
        return cached_popular.map { |f| formula_to_proposal(f) }
      end

      # No reusable cache — compose new proposals
      composer  = DietComposer.new(pet, standard, preparation_style: preparation_style)
      proposals = composer.compose(count: DietComposer::PROPOSAL_COUNT)

      raise "No se pudieron generar propuestas para #{pet.species}/#{pet.life_stage}. Verifica que haya ingredientes disponibles." if proposals.empty?

      # Persist formulas (only for homemade cooked — raw/mixed are ephemeral by design)
      if diet_type == "homemade" && preparation_style == "cooked"
        proposals.each_with_index do |proposal, i|
          DietFormula.find_or_create_by!(fingerprint: "#{fingerprint}_#{i}") do |f|
            f.name                   = proposal.name
            f.fingerprint            = "#{fingerprint}_#{i}"
            f.species                = proposal.species
            f.life_stage             = proposal.life_stage
            f.condition_ids          = proposal.condition_ids
            f.allergen_ids           = proposal.allergen_ids
            f.ingredient_composition = proposal.ingredient_composition
          end
        end
      end

      proposals
    end

    # ------------------------------------------------------------------
    # Prescribe from a chosen formula or commercial food
    # ------------------------------------------------------------------

    def prescribe(pet, formula_or_food, options = {})
      standard_name    = options[:standard_name].presence
      diet_type        = options[:diet_type].presence || "homemade"
      preparation_style = options[:preparation_style].presence || "cooked"
      custom_allergens_notes   = options[:custom_allergens_notes]
      custom_conditions_notes  = options[:custom_conditions_notes]

      calc     = DerCalculator.new(pet)
      der_kcal = calc.der
      standard = StandardMatcher.new(pet).match!(org_name: standard_name)

      if diet_type == "commercial" && formula_or_food.is_a?(CommercialFood)
        food          = formula_or_food
        daily_g       = food.daily_portion_g(der_kcal) || 0.0
        macros        = { protein_g: (food.protein_min_pct.to_f * daily_g / 100).round(2),
                          fat_g:     (food.fat_min_pct.to_f    * daily_g / 100).round(2),
                          carbs_g:   0.0, fiber_g: 0.0,
                          energy_kcal: (food.energy_kcal_per_kg.to_f * daily_g / 1000).round(2) }
        validation    = Validator.new(standard, macros, daily_g).validate

        engine_output = {
          der_kcal:        der_kcal,
          rer_kcal:        calc.rer,
          multiplier:      calc.multiplier,
          daily_portion_g: daily_g,
          macros:          macros,
          validation:      { passed: validation.passed, errors: validation.errors, warnings: validation.warnings },
          recipe_name:     food.name,
          standard_used:   "#{standard.standard_name} #{standard.version}",
          food_form:       food.food_form,
          brand:           food.brand
        }

        return DietPrescription.create!(
          pet:                     pet,
          nutritional_standard:    standard,
          commercial_food:         food,
          der_kcal:                der_kcal,
          daily_portion_g:         daily_g,
          diet_type:               "commercial",
          preparation_style:       "cooked",
          standard_override:       standard_name,
          custom_allergens_notes:  custom_allergens_notes,
          custom_conditions_notes: custom_conditions_notes,
          engine_output:           engine_output,
          final_output:            engine_output,
          rejected_recipes:        [],
          status:                  "calculated",
          source:                  "engine"
        )
      end

      # Homemade / Mixed path
      formula = formula_or_food
      composition_with_objects = formula.ingredient_composition.map do |ing_id, pct|
        [Ingredient.find(ing_id.to_i), pct.to_f]
      end

      portions   = FormulaPortionCalculator.new(composition_with_objects, der_kcal).calculate
      macros     = portions.macro_summary
      validation = Validator.new(standard, macros, portions.daily_portion_g).validate

      engine_output = {
        der_kcal:        der_kcal,
        rer_kcal:        calc.rer,
        multiplier:      calc.multiplier,
        daily_portion_g: portions.daily_portion_g,
        macros:          macros,
        validation:      { passed: validation.passed, errors: validation.errors, warnings: validation.warnings },
        recipe_name:     formula.name || "Fórmula personalizada",
        standard_used:   "#{standard.standard_name} #{standard.version}"
      }

      ActiveRecord::Base.transaction do
        prescription = DietPrescription.create!(
          pet:                     pet,
          nutritional_standard:    standard,
          diet_formula:            formula,
          der_kcal:                der_kcal,
          daily_portion_g:         portions.daily_portion_g,
          diet_type:               diet_type,
          preparation_style:       preparation_style,
          standard_override:       standard_name,
          custom_allergens_notes:  custom_allergens_notes,
          custom_conditions_notes: custom_conditions_notes,
          engine_output:           engine_output,
          final_output:            engine_output,
          rejected_recipes:        [],
          status:                  "calculated",
          source:                  "engine"
        )

        portions.items.each do |item|
          prescription.prescription_items.create!(
            ingredient:     item[:ingredient],
            daily_amount_g: item[:daily_amount_g],
            pct_of_diet:    item[:pct_of_diet],
            is_substitute:  false
          )
        end

        prescription
      end
    end

    # ------------------------------------------------------------------
    # LEGACY: Diet-based generate (used by DietRegenerationJob)
    # ------------------------------------------------------------------

    def generate(pet, options = {})
      standard_name    = options[:standard_name].presence
      diet_type        = options[:diet_type].presence || "homemade"
      preparation_style = options[:preparation_style].presence || "cooked"

      calc     = DerCalculator.new(pet)
      der_kcal = calc.der
      standard = StandardMatcher.new(pet).match!(org_name: standard_name)

      # Commercial path — just prescribe the first matching food
      if diet_type == "commercial"
        food = CommercialFood.active.for_species(pet.species).first
        return prescribe(pet, food, options) if food
      end

      candidates = Diet.active
                        .for_species(pet.species)
                        .for_life_stage(pet.life_stage)
                        .includes(:contraindicated_conditions,
                                  :contraindicated_allergens,
                                  recipe_ingredients: :ingredient)

      filter   = ContraindicationFilter.new(pet)
      safe     = filter.filter(candidates)
      rejected = filter.rejected

      # Fallback: if no specific master recipe, use formula flow
      if safe.empty?
        composer  = DietComposer.new(pet, standard, preparation_style: preparation_style)
        proposals = composer.compose(count: 1)
        raise "No se encontró receta ni fórmula segura para #{pet.species}/#{pet.life_stage}" if proposals.empty?

        proposal = proposals.first
        formula  = DietFormula.find_or_create_by!(fingerprint: "#{DietFormula.generate_fingerprint(pet)}_0") do |f|
          f.name                   = proposal.name
          f.species                = proposal.species
          f.life_stage             = proposal.life_stage
          f.condition_ids          = proposal.condition_ids
          f.allergen_ids           = proposal.allergen_ids
          f.ingredient_composition = proposal.ingredient_composition
        end
        return prescribe(pet, formula, options)
      end

      recipe     = safe.first
      portions   = PortionCalculator.new(recipe, der_kcal).calculate
      macros     = portions.macro_summary
      validation = Validator.new(standard, macros, portions.daily_portion_g).validate

      engine_output = {
        der_kcal:        der_kcal,
        rer_kcal:        calc.rer,
        multiplier:      calc.multiplier,
        daily_portion_g: portions.daily_portion_g,
        macros:          macros,
        validation:      { passed: validation.passed, errors: validation.errors, warnings: validation.warnings },
        recipe_name:     recipe.name,
        standard_used:   "#{standard.standard_name} #{standard.version}"
      }

      ActiveRecord::Base.transaction do
        prescription = DietPrescription.create!(
          pet:                  pet,
          nutritional_standard: standard,
          diet:                 recipe,
          der_kcal:             der_kcal,
          daily_portion_g:      portions.daily_portion_g,
          diet_type:            diet_type,
          preparation_style:    preparation_style,
          standard_override:    standard_name,
          engine_output:        engine_output,
          final_output:         engine_output,
          rejected_recipes:     rejected,
          status:               "calculated",
          source:               "engine"
        )

        portions.items.each do |item|
          prescription.prescription_items.create!(
            ingredient:     item[:ingredient],
            daily_amount_g: item[:daily_amount_g],
            pct_of_diet:    item[:pct_of_diet],
            is_substitute:  item[:is_substitute]
          )
        end

        prescription
      end
    end

    private

    def formula_to_proposal(formula)
      DietComposer::Proposal.new(
        name:                  formula.name,
        fingerprint:           formula.fingerprint,
        ingredient_composition: formula.ingredient_composition,
        macros:                {},
        energy_kcal_per_100g:  0,
        passes_standard:       true,
        species:               formula.species,
        life_stage:            formula.life_stage,
        condition_ids:         formula.condition_ids,
        allergen_ids:          formula.allergen_ids
      )
    end

    def commercial_food_to_proposal(food, pet)
      DietComposer::Proposal.new(
        name:                   food.name,
        fingerprint:            "commercial_#{food.id}",
        ingredient_composition: {},
        macros:                 { protein_g: food.protein_min_pct.to_f,
                                  fat_g:     food.fat_min_pct.to_f,
                                  fiber_g:   food.fiber_max_pct.to_f,
                                  carbs_g:   0.0,
                                  energy_kcal: (food.energy_kcal_per_kg.to_f / 10).round(2) },
        energy_kcal_per_100g:   (food.energy_kcal_per_kg.to_f / 10).round(2),
        passes_standard:        true,
        species:                food.species,
        life_stage:             food.life_stage || pet.life_stage,
        condition_ids:          [],
        allergen_ids:           []
      )
    end
  end
end
