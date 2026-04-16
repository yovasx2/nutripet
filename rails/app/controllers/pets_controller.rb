class PetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pet, only: [:show, :edit, :update, :destroy]

  def index
    @pets = current_user.pets.order(:name)
  end

  def show
    @latest_prescription = @pet.diet_prescriptions.latest_for_pet(@pet.id).first
  end

  def new
    @pet = current_user.pets.build
  end

  def create
    @pet = current_user.pets.build(pet_params)
    if @pet.save
      redirect_to @pet, notice: "Mascota registrada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @pet.update(pet_params)
      redirect_to @pet, notice: "Datos actualizados."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pet.destroy
    redirect_to pets_path, notice: "Mascota eliminada."
  end

  private

  def set_pet
    @pet = current_user.pets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to pets_path, alert: "Mascota no encontrada."
  end

  def pet_params
    params.require(:pet).permit(
      :name, :species, :breed, :weight_kg,
      :life_stage, :activity_level, :body_condition_score, :is_neutered,
      condition_ids: [], allergen_ids: []
    )
  end
end
