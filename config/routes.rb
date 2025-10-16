Rails.application.routes.draw do
  
  namespace :api do
    namespace :v1 do
      devise_for :users,
        defaults: { format: :json },
        controllers: {
          sessions: 'api/v1/users/sessions',
          registrations: 'api/v1/users/registrations',
          passwords: 'api/v1/users/passwords',
          confirmations: 'api/v1/users/confirmations',
          omniauth_callbacks: 'api/v1/users/omniauth_callbacks'
        }

      resources :payments
      resources :order_items
      resources :orders
      resources :products
      resources :order_items
      namespace :users do
        get 'two_factor/provision', to: 'two_factor#provision'
        post 'two_factor/confirm', to: 'two_factor#confirm'
        post 'two_factor/enable', to: 'two_factor#enable'
        post 'two_factor/disable', to: 'two_factor#disable'
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
