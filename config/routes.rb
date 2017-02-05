Rails.application.routes.draw do
  root to: 'pages#main'
  get 'states/:id', to: 'pages#state', as: :state
  resources :donations, only: :index
end
