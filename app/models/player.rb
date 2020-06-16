class Player < ApplicationRecord
  # has_many :games (association for games where player is player_one or player_two)
  def games
    games = Game.arel_table

    Game.where(games[:player_one_id].eq(id).or(games[:player_two_id].eq(id)))
        .order(created_at: :desc)
  end
end
