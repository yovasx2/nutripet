# frozen_string_literal: true

class Admin::NutritionalStandardsController < Admin::BaseController
  before_action :set_standard, only: [:show, :edit, :update]

  def index
    @standards = NutritionalStandard.order(:species, :life_stage)
  end

  def show; end

  def edit; end

  def update
    if @standard.update(standard_params)
      redirect_to admin_nutritional_standard_path(@standard), notice: "Estándar actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_standard
    @standard = NutritionalStandard.find(params[:id])
  end

  def standard_params
    params.require(:nutritional_standard).permit(
      :standard_name, :version, :species, :life_stage,
      :protein_min_pct, :protein_max_pct, :fat_min_pct, :fat_max_pct,
      :fiber_max_pct, :moisture_max_pct, :energy_min_kcal_kg, :energy_max_kcal_kg
    )
  end
end
