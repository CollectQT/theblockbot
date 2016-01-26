Rails.application.routes.draw do

  root 'index#index'

  resources :block_lists
  post   '/block_lists/:id/subscribe' => 'block_lists#subscribe',   :as => :list_subscribe
  delete '/block_lists/:id/subscribe' => 'block_lists#unsubscribe', :as => :list_unsubscribe

  get    'reports'             => 'reports#index',   :as => :reports
  get    'reports/:id'         => 'reports#show',    :as => :report
  get    'reports/new'         => 'reports#new',     :as => :report_new
  post   'reports'             => 'reports#create',  :as => :report_create
  post   'reports/:id/approve' => 'reports#approve', :as => :report_approve
  delete 'reports/:id'         => 'reports#deny',    :as => :report_deny

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout

  get '/profile' => 'users#index', :as => :profile

end
