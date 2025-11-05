Rails.application.routes.draw do
  get "canned_messages/index"
  get "canned_messages/new"
  get "canned_messages/create"
  get "canned_messages/edit"
  get "canned_messages/update"
  get "canned_messages/destroy"
  root "messages#index"
  resources :messages, only: [:index, :show, :new, :create, :update]
  resources :canned_messages

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
