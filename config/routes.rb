Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :game_moves
      resources :games
      resources :players
    end
  end
end
