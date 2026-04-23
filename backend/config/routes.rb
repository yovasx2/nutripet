Rails.application.routes.draw do
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "register"
  }, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  namespace :users do
    get "me", to: "me#show"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
