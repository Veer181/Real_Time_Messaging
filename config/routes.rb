Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "messages#index"

  resources :messages, only: [:index, :show, :new, :create] do
    resources :replies, only: [:create]
    get :new_replies, on: :member
  end
  resources :canned_messages
end
