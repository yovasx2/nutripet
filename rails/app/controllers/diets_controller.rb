class DietsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pet
  before_action :set_diet, only: [:show, :regenerate]
  before_action :block_diet_calculation_for_critical_bcs!, only: [:new, :create, :regenerate]

  def show
    redirect_to new_pet_diet_path(@pet) unless @diet

    if @diet
      @alternatives = @diet.diet_items.includes(:ingredient).each_with_object({}) do |item, h|
        h[item.id] = DietEngine.alternatives_for(@pet, @diet, item)
      end

      # Compute display data live so pet edits (body condition BCS, weight) are always reflected
      @macros = DietEngine.live_macros(@diet)
      @aafco  = DietEngine.live_aafco(@pet, @macros)

      bcs = @pet.body_condition_score.to_i
      @bcs_warning = if bcs > 5
        "Condición corporal (BCS) #{bcs}/9 — Sobrepeso. La porción calculada está reducida un #{(bcs - 5) * 5}% respecto al mantenimiento ideal."
      elsif bcs < 5
        "Condición corporal (BCS) #{bcs}/9 — Peso bajo. La porción calculada está aumentada un #{(5 - bcs) * 5}% respecto al mantenimiento ideal."
      end
      @bcs_critical = critical_bcs?
    end
  end

  def new
    @diet = Diet.new
  end

  def create
    result = DietEngine.generate(@pet, preparation_style: params[:preparation_style])
    diet = save_diet!(result)
    redirect_to pet_diet_path(@pet, diet)
  rescue => e
    flash[:alert] = "No se pudo generar la dieta: #{e.message}"
    redirect_to new_pet_diet_path(@pet)
  end

  def regenerate
    previous_excluded_ids = @diet&.engine_output&.fetch("excluded_ingredient_ids", []) || []
    ids = Array(params[:ingredient_ids]).map(&:to_i).uniq.reject(&:zero?)
    omitted_ids = @diet ? @diet.diet_items.pluck(:ingredient_id) - ids : []
    excluded_ids = (previous_excluded_ids + omitted_ids).uniq

    result = if ids.any?
      DietEngine.generate_with_ingredients(
        @pet,
        preparation_style: params[:preparation_style],
        ingredient_ids: ids,
        excluded_ingredient_ids: excluded_ids
      )
    else
      DietEngine.generate(
        @pet,
        preparation_style: params[:preparation_style],
        excluded_ingredient_ids: excluded_ids
      )
    end

    if @diet
      update_diet!(@diet, result)
    else
      @diet = save_diet!(result)
    end
    redirect_to pet_diet_path(@pet, @diet), notice: "Dieta actualizada."
  rescue => e
    flash[:alert] = "No se pudo regenerar la dieta: #{e.message}"
    redirect_to pet_diet_path(@pet, @diet)
  end

  private

  def set_pet
    @pet = current_user.pets.find(params[:pet_id])
  end

  def set_diet
    @diet = @pet.diets.find_by(id: params[:id]) || @pet.diets.order(created_at: :desc).first
  end

  def save_diet!(result)
    Diet.transaction do
      diet = @pet.diets.create!(
        der_kcal:          result[:der_kcal],
        daily_portion_g:   result[:daily_portion_g],
        preparation_style: result[:preparation_style],
        engine_output:     result[:engine_output]
      )

      result[:items].each do |item|
        diet.diet_items.create!(
          ingredient:    item[:ingredient],
          daily_amount_g: item[:daily_amount_g],
          pct_of_diet:   item[:pct_of_diet]
        )
      end

      diet
    end
  end

  def update_diet!(diet, result)
    Diet.transaction do
      diet.update!(
        der_kcal:          result[:der_kcal],
        daily_portion_g:   result[:daily_portion_g],
        preparation_style: result[:preparation_style],
        engine_output:     result[:engine_output]
      )
      diet.diet_items.destroy_all
      result[:items].each do |item|
        diet.diet_items.create!(
          ingredient:     item[:ingredient],
          daily_amount_g: item[:daily_amount_g],
          pct_of_diet:    item[:pct_of_diet]
        )
      end
      diet
    end
  end

  def critical_bcs?
    [1, 9].include?(@pet.body_condition_score.to_i)
  end

  def block_diet_calculation_for_critical_bcs!
    return unless critical_bcs?

    flash[:alert] = "BCS #{@pet.body_condition_score}/9: #{@pet.name} necesita atención veterinaria inmediata. La dieta no puede calcularse hasta valoración médica."
    redirect_to pet_path(@pet)
  end
end
