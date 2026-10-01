Rails.application.routes.draw do
  root "lockers#index"

  resources :lockers, only: %i[index show] do
    resources :locker_actions, only: :create
  end
  resource :session, only: :update
end
