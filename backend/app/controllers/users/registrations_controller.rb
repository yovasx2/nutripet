module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: {
          status: { code: 200, message: "Signed up successfully." },
          data: user_data(resource),
          token: request.env["warden-jwt_auth.token"]
        }, status: :ok
      else
        render json: {
          status: { code: 422, message: "User couldn't be created." },
          errors: resource.errors.full_messages
        }, status: :unprocessable_entity
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
