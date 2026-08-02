Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
  get "bowerbird/enter", to: "bowerbird/preview#enter"

  resources :users, except: %i[show]

  root "home#index"
end
