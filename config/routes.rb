Rails.application.routes.draw do

  root 'index#index'

  resources :auths

  resources :users

  resources :blocks

  resources :block_lists

  resources :reports
  post 'reports/:id' => 'reports#approve'

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'

end
