Rails.application.routes.draw do
  root to: 'pages#main'
  get 'sitemap', to: 'sitemap#index'
  get 'bundesland/:id', to: 'pages#state', as: :state
  get 'empfaenger/:recipient_slug', to: 'donations#index', as: :recipient
  resources :donations, only: :index
end
