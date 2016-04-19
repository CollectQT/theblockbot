Rails.application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  root 'index#index'

  # delete '/block_lists/:id/remove/blocker/:user_id' => 'block_lists#remove_blocker', :as => :remove_blocker
  resources :block_lists, except: :show
  get    '/block_lists/:id'              => 'block_lists#show', :constraints => { :id => /[0-9]+/ }, :as => :block_list_path
  get    '/block_lists/:name'            => 'block_lists#show'
  post   '/block_lists/:id/add/blocker/' => 'block_lists#add_blocker', :as => :add_blocker
  post   '/block_lists/:id/add/admin/'   => 'block_lists#add_admin',   :as => :add_admin
  post   '/block_lists/:id/subscribe'    => 'block_lists#subscribe',   :as => :list_subscribe
  delete '/block_lists/:id/subscribe'    => 'block_lists#unsubscribe', :as => :list_unsubscribe

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

  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

end
