module Users
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: {
        status: { code: 200, message: "Logged in successfully." },
        data: user_data(resource),
        token: request.env["warden-jwt_auth.token"]
      }, status: :ok
    end

    def respond_to_on_destroy(_resource = nil)
      if current_user
        render json: {
          status: 200,
          message: "Logged out successfully."
        }, status: :ok
      else
        render json: {
          status: 401,
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end
    end

    def user_data(user)
      {
        id: user.id,
        email: user.email,
        name: user.respond_to?(:name) ? user.name : nil,
        created_at: user.created_at
      }
    end
  end
end
