Rails.application.routes.draw do
  get "pages/launch", to: "pages#launch"
  get "pages/terms"
  get "pages/privacy"
  # Authentication
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  namespace :admin do
    resources :recipes, only: [:index]
  end

  # Landing page
  root "pages#launch"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
