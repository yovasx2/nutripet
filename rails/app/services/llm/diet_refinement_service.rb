# Llm::DietRefinementService
#
# Builds a structured prompt from the prescription context, sends it to the
# configured LLM adapter, and parses the JSON response back into a structured
# output that the engine Validator can then verify.
#
# Expected LLM JSON response format:
# {
#   "preparation_notes": "...",
#   "substitutions": [
#     { "original_ingredient": "...", "substitute_ingredient": "...", "reason": "..." }
#   ],
#   "feeding_schedule": "...",
#   "clinical_notes": "..."
# }

require "json"

module Llm
  class DietRefinementService
    def initialize(adapter: nil)
      @adapter = adapter || OllamaAdapter.new
    end

    def refine(prescription)
      pet      = prescription.pet
      prompt   = build_prompt(pet, prescription)
      raw      = @adapter.complete(prompt)
      parse_response(raw)
    rescue => e
      Rails.logger.error("[LLM] DietRefinementService failed: #{e.message}")
      nil
    end

    private

    def build_prompt(pet, prescription)
      output  = prescription.engine_output
      items   = prescription.prescription_items.includes(:ingredient)
      ing_list = items.map { |i| "- #{i.ingredient.name}: #{i.daily_amount_g}g (#{i.pct_of_diet}% of diet)" }.join("\n")

      conditions = pet.conditions.pluck(:name).join(", ").presence || "none"
      allergens  = pet.allergens.pluck(:name).join(", ").presence  || "none"

      <<~PROMPT
        You are a clinical veterinary nutritionist. Review the following diet prescription and provide refinements.

        PET PROFILE:
        - Species: #{pet.species}
        - Breed: #{pet.breed}
        - Weight: #{pet.weight_kg} kg
        - Life stage: #{pet.life_stage}
        - Activity level: #{pet.activity_level}
        - Neutered: #{pet.is_neutered}
        - Body condition score: #{pet.body_condition_score}/9
        - Medical conditions: #{conditions}
        - Allergens: #{allergens}

        CALCULATED DIET:
        - Daily energy requirement: #{output['der_kcal']} kcal
        - Total daily portion: #{output['daily_portion_g']}g
        - Base recipe: #{output['recipe_name']}
        - Standard: #{output['standard_used']}

        INGREDIENT LIST:
        #{ing_list}

        MACROS (daily totals):
        - Protein: #{output.dig('macros', 'protein_g')}g
        - Fat: #{output.dig('macros', 'fat_g')}g
        - Carbs: #{output.dig('macros', 'carbs_g')}g
        - Fiber: #{output.dig('macros', 'fiber_g')}g

        TASK:
        1. If any ingredient is unsafe given the conditions or allergens, suggest a substitute from common pet food ingredients.
        2. Provide practical preparation notes.
        3. Provide a simple daily feeding schedule.
        4. Add any relevant clinical notes.

        Respond ONLY in valid JSON with this exact structure:
        {
          "preparation_notes": "string",
          "substitutions": [{"original_ingredient": "string", "substitute_ingredient": "string", "reason": "string"}],
          "feeding_schedule": "string",
          "clinical_notes": "string"
        }
      PROMPT
    end

    def parse_response(raw)
      return nil if raw.blank?

      # Extract JSON block even if model wraps it in markdown fences
      json_str = raw.match(/\{.*\}/m)&.to_s
      return nil unless json_str

      JSON.parse(json_str)
    rescue JSON::ParserError => e
      Rails.logger.error("[LLM] Failed to parse response: #{e.message}")
      nil
    end
  end
end
