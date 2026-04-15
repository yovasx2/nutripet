Rails.application.routes.draw do
  get "pages/terms"
  get "pages/privacy"
  # Authentication
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  # Dashboard for authenticated users
  get "dashboard", to: "dashboard#index"

  # Landing page
  root "launch#index"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
