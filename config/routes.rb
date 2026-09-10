Rails.application.routes.draw do
  apipie

  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: [:create, :show, :destroy]
  post "register", to: "registrations#create"
  resources :users, only: [:create]
  resources :spaces
  resources :reservations, only: [:index, :create, :update] do
    member do
      patch :cancel
    end
  end

  root "pages#show"
  get "*path", to: "pages#show", constraints: ->(req) { req.format.html? }, format: false
end
