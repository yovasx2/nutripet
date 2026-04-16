class DietPrescriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pet

  def new
    @options   = proposal_options
    @proposals = DietEngine.proposals(@pet, @options)
  rescue => e
    redirect_to @pet, alert: "No fue posible generar propuestas: #{e.message}"
  end

  def show
    @prescription = @pet.diet_prescriptions.find(params[:id])
    @items        = @prescription.prescription_items.includes(:ingredient).order("ingredients.name")
  end

  def create
    opts = prescription_options

    if opts[:diet_type] == "commercial"
      food = CommercialFood.find(params[:commercial_food_id])
      prescription = DietEngine.prescribe(@pet, food, opts)
    else
      formula = DietFormula.find(params[:formula_id])
      prescription = DietEngine.prescribe(@pet, formula, opts)
    end

    redirect_to pet_diet_prescription_path(@pet, prescription),
                notice: "Dieta calculada correctamente."
  rescue => e
    redirect_to new_pet_diet_prescription_path(@pet, proposal_options),
                alert: "No fue posible calcular la dieta: #{e.message}"
  end

  # POST /pets/:pet_id/diet_prescriptions/:id/regenerate
  def regenerate
    @prescription = @pet.diet_prescriptions.find(params[:id])
    opts = {
      standard_name:    params[:standard_name].presence,
      diet_type:        params[:diet_type].presence || @prescription.diet_type,
      preparation_style: params[:preparation_style].presence || @prescription.preparation_style
    }
    DietRegenerationJob.perform_later(@pet.id, @prescription.id, opts)
    redirect_to pet_diet_prescription_path(@pet, @prescription),
                notice: "Regenerando dieta con IA, esto puede tardar unos segundos…"
  end

  # POST /pets/:pet_id/diet_prescriptions/:id/upvote
  def upvote
    @prescription = @pet.diet_prescriptions.find(params[:id])
    if @prescription.diet_formula
      @prescription.diet_formula.increment!(:upvotes_count)
    end
    @prescription.increment!(:upvotes_count)
    redirect_to pet_diet_prescription_path(@pet, @prescription),
                notice: "¡Gracias por tu valoración! Esto ayuda a mejorar las recomendaciones."
  end

  private

  def set_pet
    @pet = current_user.pets.find(params[:pet_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to pets_path, alert: "Mascota no encontrada."
  end

  # Options forwarded to DietEngine.proposals (used in new action)
  def proposal_options
    {
      standard_name:     params[:standard_name].presence,
      diet_type:         params[:diet_type].presence || "homemade",
      preparation_style: params[:preparation_style].presence || "cooked"
    }
  end

  # Options forwarded to DietEngine.prescribe (used in create action)
  def prescription_options
    proposal_options.merge(
      custom_allergens_notes:  params[:custom_allergens_notes].presence,
      custom_conditions_notes: params[:custom_conditions_notes].presence
    )
  end
end
