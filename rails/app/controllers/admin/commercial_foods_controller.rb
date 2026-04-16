class Admin::CommercialFoodsController < Admin::BaseController
  before_action :set_commercial_food, only: [:show, :edit, :update, :destroy]

  def index
    @commercial_foods = CommercialFood.order(:species, :name)
  end

  def new
    @commercial_food = CommercialFood.new
  end

  def create
    @commercial_food = CommercialFood.new(commercial_food_params)
    if @commercial_food.save
      redirect_to admin_commercial_foods_path, notice: "Alimento comercial creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @commercial_food.update(commercial_food_params)
      redirect_to admin_commercial_foods_path, notice: "Alimento comercial actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @commercial_food.destroy
    redirect_to admin_commercial_foods_path, notice: "Alimento comercial eliminado."
  end

  private

  def set_commercial_food
    @commercial_food = CommercialFood.find(params[:id])
  end

  def commercial_food_params
    params.require(:commercial_food).permit(
      :name, :brand, :species, :life_stage, :food_form,
      :protein_min_pct, :fat_min_pct, :fiber_max_pct, :moisture_max_pct,
      :energy_kcal_per_kg, :label_standard, :ingredients_list,
      :is_active, :source, :notes
    )
  end
end
