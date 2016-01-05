Rails.application.routes.draw do

  root 'index#index'

  resources :block_lists
  post   '/block_lists/:id/subscribe' => 'block_lists#subscribe',   :as => :list_subscribe
  delete '/block_lists/:id/subscribe' => 'block_lists#unsubscribe', :as => :list_unsubscribe

  get    'reports'             => 'reports#index',   :as => :reports
  get    'reports/new'         => 'reports#new',     :as => :report_new
  post   'reports'             => 'reports#create',  :as => :report_create
  get    'reports/:id'         => 'reports#show',    :as => :report_show
  post   'reports/:id/approve' => 'reports#approve', :as => :report_approve
  delete 'reports/:id'         => 'reports#deny',    :as => :report_deny

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'

end
