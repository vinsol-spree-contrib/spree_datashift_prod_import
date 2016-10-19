Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :product_imports, only: [:index] do
      collection do
        get :reset
        get :sample_import
        post :sample_csv_import
        post :user_csv_import
        get :download_sample_csv
      end
    end
  end
end
