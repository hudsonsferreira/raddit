Rails.application.routes.draw do
  devise_for :users
  namespace :admins do
    resources :links
  end

  root to: "admins/links#index"
end
