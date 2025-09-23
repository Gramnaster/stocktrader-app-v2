Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :stocks, only: [ :index, :show ]
      resources :countries, only: [ :index, :show ]
      resources :wallets, only: [ :index, :show ]
      resources :historical_prices, only: [ :index, :show ]
      resources :portfolios, only: [ :index, :show ]
      # resources :transactions, only: [ :index, :show ]
      resources :receipts, only: [ :index, :show ]
      resources :stock_reviews, only: [ :index, :show ]
    end
  end

  devise_for :users, path: "api/v1/users", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup"
  },
  controllers: {
    sessions: "api/v1/users/sessions",
    registrations: "api/v1/users/registrations"
  }

  # Defines the root path route ("/")
  # root "posts#index"
end
