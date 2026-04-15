# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_superadmin!

  private

  def ensure_superadmin!
    return if current_user&.superadmin?

    flash[:alert] = "Acceso restringido al panel de administración."
    redirect_to(root_path)
  end
end
