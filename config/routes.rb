Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :promotions do
      member do
        get :export_promotions
        get :bulk_load
        get :sub_promotions
        post :automatic_load
        post :manual_load
      end
    end
  end
end
