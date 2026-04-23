module Users
  class MeController < ApplicationController
    before_action :authenticate_user!

    def show
      render json: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.respond_to?(:name) ? current_user.name : nil,
        created_at: current_user.created_at
      }
    end
  end
end
