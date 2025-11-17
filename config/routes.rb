Rails.application.routes.draw do
  # --- Devise routes (initialized first, but still under /api/v1 path) ---
  devise_for :users,
             path: 'api/v1/users',
            #  defaults: { format: :json },
             controllers: {
               sessions: 'api/v1/users/sessions',
               registrations: 'api/v1/users/registrations',
               passwords: 'api/v1/users/passwords',
               confirmations: 'api/v1/users/confirmations',
              omniauth_callbacks: 'api/v1/users/omniauth_callbacks'
             }

  # --- API routes ---
  namespace :api do
    namespace :v1 do
      # Custom users endpoints
      get '/sellers', to: 'users#sellers'
      get '/users/me', to: 'users#me'
      put '/users/setup', to: 'users#setup'
      resources :users, only: [:index, :show, :update, :destroy, :create]

      # Main business entities
      resources :categories, only: [:index, :show, :create, :update, :destroy]
      resources :products
      resources :orders
      resources :order_items
      resources :payments

  # Token refresh endpoint for rotating JWTs
  post '/users/refresh', to: 'users/token_refresh#create'

      # Two-factor authentication endpoints
      namespace :users do
        get 'two_factor/provision', to: 'two_factor#provision'
        post 'two_factor/confirm', to: 'two_factor#confirm'
        post 'two_factor/enable', to: 'two_factor#enable'
        post 'two_factor/disable', to: 'two_factor#disable'
      end

      # Admin namespace for management endpoints
      namespace :admin do
        resources :users, only: [:index, :show] do
          member do
            put 'deactivate'
            put 'reactivate'
            patch 'update'
          end
        end
        resources :products, only: [] do
          member do
            put 'transfer'
          end
        end
      end
    end
  end

  # Development-only email preview UI
  if Rails.env.development?
    begin
      mount LetterOpenerWeb::Engine, at: '/letter_opener'
    rescue NameError
      # letter_opener_web not installed; skip mounting
    end
  end

end
