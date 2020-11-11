Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'welcome#index'
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:index, :show]
    resources :orders, only: [:update]
    resources :merchants, only: [:index, :show, :update]
    namespace :merchants do
      scope '/:merchant_id/' do
        resources :items, except: [:show]
      end
    end
  end

  namespace :merchant do
    root 'dashboard#index'
    resources :items, except: [:show]
    resources :bulk_discounts, except: [:show]
    get '/orders/:order_id', to: "orders#show"
    patch '/orders/:order_id', to: "orders#update"
  end

  resources :merchants, except: [:delete]
  get "/merchants/:merchant_id/items", to: 'items#index'

  resources :items, only: [:index, :show]

  get "/items/:item_id/reviews/new", to: "reviews#new"
  post "/items/:item_id/reviews", to: "reviews#create"

  resources :reviews, only: [:edit, :update]
  delete "/reviews/:id", to: "reviews#destroy"

  post "/cart/:item_id", to: "cart#create"
  patch "/cart/:item_id", to: "cart#update"
  get "/cart", to: "cart#show"
  patch "/cart", to: "cart#address"
  delete "/cart", to: "cart#destroy"
  delete "/cart/:item_id", to: "cart#destroy"

  namespace :profile do
    get "/orders", to: "orders#index"
    get "/orders/:id", to: "orders#show", as: "order_show"
    patch "/orders/:id", to: "orders#update"
    get "/orders/:id/edit", to: "orders#edit", as: "order_edit"
    resources :addresses, except: [:show]
  end

  get "/orders/new", to: "orders#new"
  post "/orders", to: "orders#create"
  get "/orders/:id", to: "orders#show"

  get "/register", to: "users#new"
  post "/users", to: "users#create"
  get "/profile", to: "users#show"
  get "/profile/edit", to: "users#edit"
  patch "/profile", to: "users#update"
end
