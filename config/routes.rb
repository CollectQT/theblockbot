Rails.application.routes.draw do

  root 'index#index'

  # delete '/block_lists/:id/remove/blocker/:user_id' => 'block_lists#remove_blocker', :as => :remove_blocker
  post   '/block_lists/:id/add/blocker/' => 'block_lists#add_blocker', :as => :add_blocker
  post   '/block_lists/:id/subscribe'    => 'block_lists#subscribe',   :as => :list_subscribe
  delete '/block_lists/:id/subscribe'    => 'block_lists#unsubscribe', :as => :list_unsubscribe
  resources :block_lists

  post   'reports/:id/approve' => 'reports#approve', :as => :report_approve
  get    'reports/new'         => 'reports#new',     :as => :report_new
  get    'reports/:id'         => 'reports#show',    :as => :report
  delete 'reports/:id'         => 'reports#deny',    :as => :report_deny
  post   'reports'             => 'reports#create',  :as => :report_create
  get    'reports'             => 'reports#index',   :as => :reports

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout

  get '/profile' => 'users#index', :as => :profile
  get '/user/reports' => 'users#reports', :as => :user_reports

  # config/routes.rb
  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

end
