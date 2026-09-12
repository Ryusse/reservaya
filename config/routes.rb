Rails.application.routes.draw do
  apipie

  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: [:create, :show, :destroy]
  post "register", to: "registrations#create"
  resources :users
  resources :spaces
  resources :reservations, only: [:index, :show, :create] do
    member do
      patch :cancel
    end
  end

  root "pages#show"
  get "*path", to: "pages#show", constraints: ->(req) { req.format.html? }, format: false
  resource :dashboard, only: [:show]
end
