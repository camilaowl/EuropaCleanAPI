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

    get 'spaces', to: 'spaces#index'
    post 'spaces', to: 'spaces#create'
    get 'spaces/:id', to: 'spaces#show'
    patch 'spaces/:id', to: 'spaces#update'
    delete 'spaces/:id', to: 'spaces#destroy'

    get 'spaces/:space_id/rooms', to: 'rooms#index'
    post 'spaces/:space_id/rooms', to: 'rooms#create'
    get 'spaces/:space_id/rooms/:id', to: 'rooms#show'
    patch 'spaces/:space_id/rooms/:id', to: 'rooms#update'
    delete 'spaces/:space_id/rooms/:id', to: 'rooms#destroy'
  end
end
