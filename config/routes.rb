Rails.application.routes.draw do
  root "lockers#index"

  resources :lockers, only: :index
  resource :session, only: :update
end
