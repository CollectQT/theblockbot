Rails.application.routes.draw do

  resources :blocks
  resources :subscriptions
  root 'index#index'

  resources :blocks

  resources :block_lists
  post '/block_lists/:id/subscribe' => 'block_lists#subscribe', :as => :subscribe

  resources :reports
  post 'reports/:id/approve' => 'reports#approve', :as => :approve

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'

end
