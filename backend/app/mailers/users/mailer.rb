module Users
  class Mailer < Devise::Mailer
    default template_path: "devise/mailer"

    def reset_password_instructions(record, token, opts = {})
      @token = token
      @resource = record
      @frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:8080")
      opts[:subject] = "Instrucciones para restablecer tu contraseña"
      super
    end
  end
end
