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

  # Pet profiles + nested diets
  resources :pets do
    resources :diets, only: [:show, :new, :create] do
      patch :regenerate, on: :member
    end
  end

  # Admin panel
  namespace :admin do
    resources :ingredients
  end

  # Landing page
  root "pages#launch"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
