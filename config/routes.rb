Rails.application.routes.draw do
  root "lockers#index"

  resources :lockers, only: %i[index show]
  resource :session, only: :update
end
