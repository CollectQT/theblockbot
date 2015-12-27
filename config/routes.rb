Rails.application.routes.draw do

  root 'index#index'

  resources :blocks

  resources :block_lists

  resources :reports
  post 'reports/:id' => 'reports#approve'

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'

end
