Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: "users/sessions",
        registrations: "users/registrations"
      }
      resources :stocks, only: [ :index, :show ]
      resources :countries, only: [ :index, :show ]
      resources :wallets, only: [ :index, :show ]
      resources :historical_prices, only: [ :index, :show ]
      resources :portfolios, only: [ :index, :show ]
      resources :transactions, only: [ :index, :show ]
      resources :stock_reviews, only: [ :index, :show ]
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
