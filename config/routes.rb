Rails.application.routes.draw do
  # Keep the Devise mapping used by authenticate_user! and devise-jwt without
  # exposing Devise's HTML/session endpoints. Authentication is JSON-only below.
  devise_for :users, skip: :all

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :auth do
      post 'sign_up', to: 'registrations#create'
      post 'sign_in', to: 'sessions#create'
      post 'google', to: 'google_sessions#create'
      delete 'sign_out', to: 'sessions#destroy'
    end
  end
end
