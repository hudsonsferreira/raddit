Rails.application.routes.draw do
  devise_for :users
  namespace :admin do
    resources :links
  end

  root to: "admin/links#index"
end
