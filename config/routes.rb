Rails.application.routes.draw do

  puts "Routes loaded"
  devise_scope :user do
    get '/koko' => 'users/omniauth_callbacks#twitter'
  end
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  
  root 'pages#home'
end
