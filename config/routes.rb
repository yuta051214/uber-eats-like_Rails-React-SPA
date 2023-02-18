Rails.application.routes.draw do
  # app/controllers/api/vi にコントローラを作成する
  namespace :api do
    namespace :v1 do
      resources :restaurants do  # /api/v1/restaurants/(:id)
        resources :foods, only: [:index]  # /api/v1/restaurants/:id/foods
      end
      resources :line_foods, only: [:index, :create]  # /api/v1/line_foods
      put 'line_foods/replace', to: 'line_foods#replace'  # /api/v1/line_foods/replace
      resources :orders, only: [:create]  # /api/v1/orders
    end
  end
end
