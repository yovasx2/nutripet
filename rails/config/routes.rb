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

  # Pet profiles + nested prescriptions
  resources :pets do
    resources :diet_prescriptions, only: [:new, :show, :create] do
      member do
        post :regenerate
        post :upvote
      end
    end
  end

  # Admin panel
  namespace :admin do
    resources :ingredients
    resources :nutritional_standards, only: [:index, :show, :edit, :update]
    resources :commercial_foods
  end

  # Landing page
  root "pages#launch"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
