Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :game_moves
      resources :games, except: [:update, :destroy] do
        post :attack
        put :attack
      end
      resources :players
    end
  end
end
