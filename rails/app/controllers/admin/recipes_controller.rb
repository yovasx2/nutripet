# frozen_string_literal: true

class Admin::RecipesController < Admin::BaseController
  def index
    @recipes = [
      { name: "Base Renal Avanzada", protein: "14.5%", kcal: "380", status: "Activa" },
      { name: "Cachorro Crecimiento Plus", protein: "28.0%", kcal: "450", status: "Activa" },
      { name: "Control de Peso Adulto", protein: "22.3%", kcal: "330", status: "Borrador" }
    ]
  end
end
