Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :product_imports, only: [:index] do
      collection do
        get :reset
        get :sample_import
        post :import
      end
    end
  end
end
