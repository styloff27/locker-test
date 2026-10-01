Rails.application.routes.draw do
  root "pages#home"

  resource :session, only: :update
end
