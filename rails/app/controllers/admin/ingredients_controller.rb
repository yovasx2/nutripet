# frozen_string_literal: true

class Admin::IngredientsController < Admin::BaseController
  before_action :set_ingredient, only: [:show, :edit, :update, :destroy]

  def index
    @ingredients = Ingredient.order(:name)
  end

  def show; end

  def new
    @ingredient = Ingredient.new
  end

  def create
    @ingredient = Ingredient.new(ingredient_params)
    @ingredient.is_custom = true
    if @ingredient.save
      redirect_to admin_ingredient_path(@ingredient), notice: "Ingrediente creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @ingredient.update(ingredient_params)
      redirect_to admin_ingredient_path(@ingredient), notice: "Ingrediente actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ingredient.destroy
    redirect_to admin_ingredients_path, notice: "Ingrediente eliminado."
  end

  private

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end

  def ingredient_params
    params.require(:ingredient).permit(
      :name, :source, :species_safe,
      :protein_g, :fat_g, :carbs_g, :fiber_g, :moisture_g, :energy_kcal, :notes
    )
  end
end
