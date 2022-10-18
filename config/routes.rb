Rails.application.routes.draw do
  root 'companies#index'
  resources :companies, only: [:index, :new, :create] do
    collection do
      get 'filter'
    end
  end
end
