Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  } 
  
  root to: 'home#index'
  get  '/help',    to: 'home#help'
  get  '/about',   to: 'home#about'
  get  '/contact', to: 'home#contact'
  
  resources :users do
    member do
      get :following, :followers, :likes
    end
  end
  
  resources :microposts, only: [:show,   :create, :destroy] do
    resources :comments, only: [:create, :destroy]
  end
  
  get '/microposts', to: redirect("/")
  get '/microposts/:id/comments', to: redirect("/")

  
  resources :relationships,          only: [:create, :destroy]
  
  resources :favorite_relationships, only: [:create, :destroy]
  
  resources :notifications,          only: [:index,  :destroy]
  
end