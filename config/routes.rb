Rails.application.routes.draw do
  resources :companies do
    collection do
      get 'order'
      get 'filter'
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
