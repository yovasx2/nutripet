class PetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pet, only: [:update, :destroy]

  def index
    render json: current_user.pets.order(:created_at)
  end

  def create
    pet = current_user.pets.build(pet_params)
    if pet.save
      render json: pet, status: :created
    else
      render json: { errors: pet.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @pet.update(pet_params)
      render json: @pet
    else
      render json: { errors: @pet.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @pet.destroy
    head :no_content
  end

  private

  def set_pet
    @pet = current_user.pets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def pet_params
    params.require(:pet).permit(
      :name, :breed, :sex, :age_years, :age_months, :weight,
      :activity_level, :life_stage, :ecc_score, :reproductive_status,
      :selected_kibble_id
    )
  end
end
