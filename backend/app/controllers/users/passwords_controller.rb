module Users
  class PasswordsController < Devise::PasswordsController
    respond_to :json

    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      if successfully_sent?(resource)
        render json: {
          status: { code: 200, message: "Si el correo existe, recibirás instrucciones para restablecer tu contraseña." }
        }, status: :ok
      else
        render json: {
          status: { code: 422, message: "No se pudo enviar el correo de recuperación." },
          errors: resource.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    def update
      self.resource = resource_class.reset_password_by_token(resource_params)
      if resource.errors.empty?
        render json: {
          status: { code: 200, message: "Contraseña actualizada correctamente." }
        }, status: :ok
      else
        render json: {
          status: { code: 422, message: "No se pudo actualizar la contraseña." },
          errors: resource.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end
end
