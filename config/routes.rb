Rails.application.routes.draw do

  root 'index#index'

  resources :block_lists
  post   '/block_lists/:id/subscribe' => 'block_lists#subscribe',   :as => :list_subscribe
  delete '/block_lists/:id/subscribe' => 'block_lists#unsubscribe', :as => :list_unsubscribe

  post   'reports/:id/approve' => 'reports#approve', :as => :report_approve
  get    'reports/new'         => 'reports#new',     :as => :report_new
  get    'reports/:id'         => 'reports#show',    :as => :report
  delete 'reports/:id'         => 'reports#deny',    :as => :report_deny
  post   'reports'             => 'reports#create',  :as => :report_create
  get    'reports'             => 'reports#index',   :as => :reports

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout

  get '/profile' => 'users#index', :as => :profile

  # config/routes.rb
  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

end
