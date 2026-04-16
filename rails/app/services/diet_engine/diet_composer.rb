# DietEngine::DietComposer
#
# Dynamically assembles ingredient-based diet formulas from the available
# ingredient catalog, guided by AAFCO/FEDIAF nutritional targets.
#
# Strategy:
#   - Load all permitted ingredients for the pet (species-safe, non-toxic, no allergens)
#   - Group by category: protein / carb / vegetable / fat
#   - For each unique protein source, compose one formula proposal
#   - Validate each proposal against the nutritional standard
#   - Return up to `count` valid proposals as DietFormula-like structs
#
# Cats are obligate carnivores: no carbs in cat formulas.
# Dogs tolerate moderate carbohydrates.

module DietEngine
  class DietComposer
    PROPOSAL_COUNT = 3

    # Dogs: target composition ranges (% of total diet, as-fed)
    DOG_COMPOSITION = {
      protein:   { min: 45, max: 65 },
      carb:      { min: 15, max: 30 },
      vegetable: { min: 10, max: 20 },
      fat:       { min: 3,  max: 8  }
    }.freeze

    # Cats: obligate carnivores — no carbs
    CAT_COMPOSITION = {
      protein:   { min: 60, max: 75 },
      carb:      { min: 0,  max: 0  },
      vegetable: { min: 10, max: 20 },
      fat:       { min: 3,  max: 8  }
    }.freeze

    Proposal = Struct.new(:name, :fingerprint, :ingredient_composition,
                          :macros, :energy_kcal_per_100g,
                          :passes_standard, :species, :life_stage,
                          :condition_ids, :allergen_ids,
                          keyword_init: true)

    def initialize(pet, standard, preparation_style: "cooked")
      @pet               = pet
      @standard          = standard
      @preparation_style = preparation_style
    end

    def compose(count: PROPOSAL_COUNT)
      pool = Ingredient.permitted_for(@pet).includes([])

      # Raw diet: only ingredients safe to serve uncooked
      pool = pool.raw_safe if @preparation_style == "raw"

      # Therapeutic boost: if pet has conditions, sort matching ingredients first
      condition_ids = @pet.conditions.pluck(:id)
      proteins   = boost_therapeutic(pool.proteins,   condition_ids)
      carbs      = @pet.dog? ? boost_therapeutic(pool.carbs, condition_ids) : []
      vegetables = boost_therapeutic(pool.vegetables, condition_ids)
      fats       = pool.fats.to_a

      return [] if proteins.empty? || vegetables.empty?

      # Build one proposal per distinct protein source (up to `count`)
      proposals = []
      proteins.first(count + 2).each do |protein|
        composition = build_composition(protein, carbs, vegetables, fats)
        macros      = compute_macros(composition)
        passes      = validate_macros(macros)
        name        = auto_name(protein)

        proposals << Proposal.new(
          name:                  name,
          fingerprint:           DietFormula.generate_fingerprint(@pet),
          ingredient_composition: composition.transform_keys { |i| i.id.to_s },
          macros:                macros,
          energy_kcal_per_100g:  macros[:energy_kcal].round(2),
          passes_standard:       passes,
          species:               @pet.species,
          life_stage:            @pet.life_stage,
          condition_ids:         @pet.conditions.order(:id).pluck(:id),
          allergen_ids:          @pet.allergens.order(:id).pluck(:id)
        )

        break if proposals.size >= count
      end

      proposals
    end

    private

    # Derive as-fed composition targets from the nutritional standard.
    # Standard values are on a dry-matter (DM) basis; fresh/homemade ingredients
    # carry ~65-70 % moisture, so as-fed percentages must be ~2.5× higher to
    # achieve the same DM nutrient level.
    # Fat and vegetable/carb ranges remain as species-based heuristics since
    # standards do not specify as-fed ingredient proportions for those groups.
    def composition_targets
      @composition_targets ||= begin
        dm_to_as_fed = 2.5
        protein_min  = ((@standard.protein_min_pct || 18).to_f * dm_to_as_fed).ceil.clamp(35, 70)
        protein_max  = [protein_min + 20, 80].min
        fat_floor    = (@standard.fat_min_pct || 5).to_f.ceil.clamp(3, 10)
        fat_ceiling  = [fat_floor + 5, 15].min

        {
          protein:   { min: protein_min, max: protein_max },
          carb:      @pet.dog? ? { min: 10, max: 25 } : { min: 0, max: 0 },
          vegetable: { min: 10, max: 20 },
          fat:       { min: fat_floor, max: fat_ceiling }
        }
      end
    end

    def build_composition(protein, carbs, vegetables, fats)
      composition = {}

      # Protein: dominant ingredient
      protein_pct = rand(composition_targets[:protein][:min]..composition_targets[:protein][:max])
      composition[protein] = protein_pct
      remaining = 100 - protein_pct

      # Fat supplement
      fat_pct = rand(composition_targets[:fat][:min]..composition_targets[:fat][:max])
      if (fat = fats.first)
        composition[fat] = fat_pct
        remaining -= fat_pct
      end

      # Carb (dogs only)
      if carbs.any? && composition_targets[:carb][:max].positive?
        carb_pct = rand(composition_targets[:carb][:min]..composition_targets[:carb][:max])
        carb_pct = [carb_pct, remaining - composition_targets[:vegetable][:min]].min
        carb_pct = [carb_pct, 0].max
        if carb_pct.positive? && (carb = carbs.sample)
          composition[carb] = carb_pct
          remaining -= carb_pct
        end
      end

      # Vegetables: fill remaining, split across 1-2 veggies
      veg_slice = vegetables.first(2)
      if veg_slice.size == 2
        split = remaining / 2
        composition[veg_slice[0]] = split.floor
        composition[veg_slice[1]] = remaining - split.floor
      elsif veg_slice.size == 1
        composition[veg_slice[0]] = remaining
      end

      # Normalise to exactly 100
      total = composition.values.sum
      if total != 100 && composition.any?
        last = composition.keys.last
        composition[last] += (100 - total)
      end

      composition
    end

    def compute_macros(composition)
      totals = { protein_g: 0.0, fat_g: 0.0, carbs_g: 0.0,
                 fiber_g: 0.0, energy_kcal: 0.0 }

      composition.each do |ingredient, pct|
        factor = pct.to_f / 100.0
        totals[:protein_g]  += ingredient.protein_g.to_f  * factor
        totals[:fat_g]      += ingredient.fat_g.to_f      * factor
        totals[:carbs_g]    += ingredient.carbs_g.to_f    * factor
        totals[:fiber_g]    += ingredient.fiber_g.to_f    * factor
        totals[:energy_kcal]+= ingredient.energy_kcal.to_f * factor
      end

      totals.transform_values { |v| v.round(2) }
    end

    def validate_macros(macros)
      energy_per_kg = macros[:energy_kcal] * 10  # kcal/100g → kcal/kg DM (approx)

      protein_pct = macros[:protein_g]
      fat_pct     = macros[:fat_g]

      protein_ok = protein_pct >= @standard.protein_min_pct.to_f
      fat_ok     = fat_pct >= @standard.fat_min_pct.to_f

      protein_max = @standard.respond_to?(:protein_max_pct) && @standard.protein_max_pct
      protein_ok &&= protein_pct <= protein_max if protein_max

      protein_ok && fat_ok
    end

    def auto_name(protein)
      base = protein.name.split(" ").first(2).join(" ")
      stage_label = { "puppy" => "Cachorro", "kitten" => "Cachorro",
                      "adult" => "Adulto", "senior" => "Senior",
                      "pregnant" => "Gestación", "lactating" => "Lactancia" }
      species_label = @pet.dog? ? "Perro" : "Gato"
      prep_suffix   = @preparation_style == "raw" ? " (Cruda)" : ""
      "Fórmula #{base} #{species_label} #{stage_label[@pet.life_stage] || @pet.life_stage.capitalize}#{prep_suffix}"
    end

    # Move therapeutic ingredients to the front of the list.
    # Keeps original order for non-matching ingredients.
    def boost_therapeutic(relation, condition_ids)
      return relation.to_a if condition_ids.empty?
      all = relation.to_a
      therapeutic = all.select { |i| (i.therapeutic_for.to_a & condition_ids).any? }
      rest        = all - therapeutic
      therapeutic + rest
    end
  end
end
