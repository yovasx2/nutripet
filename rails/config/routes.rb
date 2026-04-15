Rails.application.routes.draw do
  # Authentication
  devise_for :users

  # Landing page
  root "launch#index"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
