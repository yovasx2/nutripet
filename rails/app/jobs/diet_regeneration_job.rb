# DietRegenerationJob
#
# Handles the full regenerate-with-AI pipeline:
#   1. Rebuild deterministic prescription from scratch (engine)
#   2. Run LLM refinement
#   3. Validate LLM output
#   4. Accept or fall back silently to engine result
#   5. Mark as needs_review internally if LLM failed validation (never shown to user)
#
# Triggered by DietPrescriptionsController#regenerate action.

class DietRegenerationJob < ApplicationJob
  queue_as :default

  def perform(pet_id, original_prescription_id, options = {})
    pet = Pet.find(pet_id)

    # Step 1: Full deterministic recalculation (new prescription record)
    new_prescription = DietEngine.generate(pet, options)

    # Step 2: Update LLM status to pending so UI can show a loading state
    new_prescription.update!(llm_status: "pending")

    # Step 3: LLM refinement
    llm_result = Llm::DietRefinementService.new.refine(new_prescription)

    if llm_result.present?
      # Step 4: Build merged output (keep numeric portions, overlay LLM text fields)
      merged = new_prescription.engine_output.merge(
        "preparation_notes" => llm_result["preparation_notes"],
        "feeding_schedule"  => llm_result["feeding_schedule"],
        "clinical_notes"    => llm_result["clinical_notes"],
        "substitutions"     => llm_result["substitutions"] || []
      )

      # Step 5: Basic validation check on the merged output
      standard   = new_prescription.nutritional_standard
      macros     = new_prescription.engine_output["macros"].transform_keys(&:to_sym)
      portion_g  = new_prescription.daily_portion_g
      validation = DietEngine::Validator.new(standard, macros, portion_g).validate

      if validation.passed
        new_prescription.update!(
          llm_output:  llm_result,
          final_output: merged,
          llm_status:  "done",
          status:      "ai_refined",
          source:      "llm_refined"
        )
      else
        # LLM failed validation — keep engine result, flag internally only
        new_prescription.update!(
          llm_output: llm_result,
          llm_status: "done",
          status:     "needs_review"
          # final_output remains engine_output — user sees clean diet
        )
        Rails.logger.warn("[DietRegenerationJob] LLM validation failed for prescription #{new_prescription.id}: #{validation.errors}")
      end
    else
      # LLM returned nothing usable — silently use engine result
      new_prescription.update!(llm_status: "failed")
    end

  rescue => e
    Rails.logger.error("[DietRegenerationJob] Failed for pet #{pet_id}: #{e.message}")
    # If the new prescription was created, mark it as calculated (engine result still valid)
    new_prescription&.update(llm_status: "failed") rescue nil
  end
end
