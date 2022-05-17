require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  get '/search', to: 'pages#search', as: 'search'

  resources :friends, only: [:index] do
    post 'follow', on: :member
    delete 'unfollow', on: :member
  end
  resources :profiles, only: [:show]
  root 'pages#home'
end
