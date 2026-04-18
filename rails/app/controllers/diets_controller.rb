class DietsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pet
  before_action :set_diet, only: [:show, :regenerate]
  before_action :block_diet_calculation_for_critical_bcs!, only: [:new, :create, :regenerate]

  def show
    redirect_to new_pet_diet_path(@pet) unless @diet

    if @diet
      @fixed_set_plan = @diet.engine_output["fixed_set_plan"] || {}
      @plan_recipes = @fixed_set_plan["recipes"] || []
      @validation_report = @fixed_set_plan["validation_report"] || {}

      if @plan_recipes.blank?
        @plan_recipes = [
          {
            "name" => "Receta activa",
            "kcal_target" => @diet.der_kcal,
            "total_g" => @diet.daily_portion_g,
            "items" => @diet.diet_items.includes(:ingredient).map do |item|
              {
                "ingredient_id" => item.ingredient_id,
                "ingredient_name" => item.ingredient.name,
                "category" => item.ingredient.category,
                "daily_amount_g" => item.daily_amount_g,
                "score" => 0.0
              }
            end
          }
        ]
      end

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
    plan_mode = normalize_plan_mode(params[:diet_mode] || params[:preparation_style])
    result = build_fixed_plan_result(
      preparation_style: plan_mode,
      diet_mode: plan_mode
    )
    diet = save_diet!(result)
    redirect_to pet_diet_path(@pet, diet)
  rescue => e
    flash[:alert] = "No se pudo generar el plan: #{e.message}"
    redirect_to new_pet_diet_path(@pet)
  end

  def regenerate
    total_kcal_set = @diet&.engine_output&.dig("fixed_set_plan", "total_kcal_set")
    current_mode = @diet&.engine_output&.dig("fixed_set_plan", "diet_mode") || @diet.preparation_style
    plan_mode = normalize_plan_mode(params[:diet_mode] || params[:preparation_style] || current_mode)

    result = build_fixed_plan_result(
      preparation_style: plan_mode,
      diet_mode: plan_mode,
      total_kcal_set: total_kcal_set
    )

    if @diet
      update_diet!(@diet, result)
    else
      @diet = save_diet!(result)
    end
    redirect_to pet_diet_path(@pet, @diet), notice: "Plan actualizado."
  rescue => e
    flash[:alert] = "No se pudo regenerar el plan: #{e.message}"
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

  def build_fixed_plan_result(preparation_style:, diet_mode:, total_kcal_set: nil)
    mode = normalize_plan_mode(diet_mode || preparation_style)
    style = mode

    payload = DietEngine.generate_fixed_set(
      @pet,
      total_kcal_set: total_kcal_set,
      diet_mode: mode
    )

    plan = payload.fetch(:fixed_set_plan)
    active_recipe = Array(plan[:recipes]).first || {}
    recipe_items = Array(active_recipe[:items])

    serializable_recipes = Array(plan[:recipes]).map do |recipe|
      {
        name: recipe[:name],
        kcal_target: recipe[:kcal_target].to_f.round(2),
        total_g: recipe[:total_g].to_f.round(2),
        items: Array(recipe[:items]).map do |item|
          ing = item[:ingredient]
          {
            ingredient_id: ing.id,
            ingredient_name: ing.name,
            category: ing.category,
            daily_amount_g: item[:daily_amount_g].to_f.round(2),
            score: item[:score].to_f.round(3)
          }
        end
      }
    end

    items = recipe_items.map do |item|
      {
        ingredient: item[:ingredient],
        daily_amount_g: item[:daily_amount_g].to_f.round(1),
        pct_of_diet: item[:pct_of_diet].to_f.round(2)
      }
    end

    macros = summarize_macros(items)

    {
      der_kcal: active_recipe[:kcal_target].to_f.round(1),
      daily_portion_g: active_recipe[:total_g].to_f.round(1),
      preparation_style: style,
      items: items,
      engine_output: {
        "macros" => macros,
        "aafco" => DietEngine.live_aafco(@pet, macros),
        "preparation_notes" => DietEngine::PREP_NOTES[style],
        "fixed_set_plan" => {
          "recipe_count" => plan[:recipe_count],
          "total_kcal_set" => plan[:total_kcal_set].to_f.round(2),
          "kcal_per_recipe" => plan[:kcal_per_recipe].to_f.round(2),
          "diet_mode" => plan[:diet_mode],
          "retries_used" => plan[:retries_used],
          "optimization_mode" => plan[:optimization_mode],
          "premix" => plan[:premix],
          "recipes" => serializable_recipes,
          "validation_report" => plan[:validation_report]
        }
      }
    }
  end

  def summarize_macros(items)
    total_g = items.sum { |item| item[:daily_amount_g].to_f }
    return {} if total_g <= 0

    {
      "protein_g" => items.sum { |item| item[:ingredient].protein_g.to_f * item[:daily_amount_g].to_f / 100.0 }.round(1),
      "fat_g" => items.sum { |item| item[:ingredient].fat_g.to_f * item[:daily_amount_g].to_f / 100.0 }.round(1),
      "carbs_g" => items.sum { |item| item[:ingredient].carbs_g.to_f * item[:daily_amount_g].to_f / 100.0 }.round(1),
      "moisture_g" => items.sum { |item| item[:ingredient].moisture_g.to_f * item[:daily_amount_g].to_f / 100.0 }.round(1),
      "total_g" => total_g.round(1)
    }
  end

  def normalize_plan_mode(value)
    mode = value.to_s
    return mode if Diet::PREP_STYLES.key?(mode)

    "cooked"
  end
end
