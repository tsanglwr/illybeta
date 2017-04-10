Rails.application.routes.draw do

  # Home, sales, informational pages
  #
  get "/about", to: "home#about", as: "about"
  get "/terms-of-use", to: "home#tos", as: "tos"
  get "/privacy-policy", to: "home#pp", as: "pp"

  # Allow user+email sign up, along with choice Oauth providers (ex: twitter, facebook)
  devise_for :users,
             :controllers => { :omniauth_callbacks => 'omniauth_callbacks', :registrations => 'custom_devise/registrations', :sessions => 'custom_devise/sessions', :passwords => 'custom_devise/passwords' }

  # A user of a system may manage multiple accounts
  resources :users

  resources :face_match_results do
      resources :face_matches
  end

  get "/face_match_results/:id/processing" => 'face_match_results#processing', :as => 'face_match_result_processing'

  #
  # Dashboard
  #

  scope "/dashboards/:account_uuid", :as => 'dashboard' do
    resources :services
    resources :activity_stream
  end

  get "/dashboards/:account_uuid" => 'dashboards#index', :as => 'dashboards'

  get "/dashboards" => 'dashboards#base', :as => 'dashboard_init_path'
  #
  # Account bootstrapping screens
  #
  # @note: Authorization and omni auth intermediate steps to get a user fully onboard.
  # For instance: Twitter does not provide a user name, while facebook does
  # Additionally, you may want a quick 'configuration' step for a subdomain for the user
  # In the latter case, you will prompt for the field in setup_site
  match '/users/:id/setup' => 'users#setup', via: [:get, :patch], :as => :setup
  match '/users/:id/setup_site' => 'users#setup_site', via: [:get, :patch], :as => :setup_site
  
  #
  # Client API
  #
  # Provides restful api to all clients
  namespace :service do
    # Validator allows pre-sign up validation (ex: username in use)
    get '/v1/setup/validate' => 'setup_validator#validate', as: 'api_setup_sites_validate'
    # Simple newsletter subscription request (for those seeking to signup to Our Very Own Newsletter)
    post '/v1/newsletter_subscriptions' => 'api_newsletter_subscriptions#create', as: 'api_newsletter_subscriptions_create'
  end

  #
  # Housekeeping
  #

  # Verifies that the user has an account and is the manager of at least one account, then redirects to the appropriate site page
  # This is useful for handling Twitter/Facebook/Oauth logins where the email is not provided and we need an email or password
  get '/init', to: 'init#index', as: 'init'
  get "sitemap.xml" => "sitemaps#index", :format => "xml", :as => :sitemap

  # Route to home if no other routes match
  root to: 'home#index'
end
