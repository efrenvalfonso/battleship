class GameMove < ApplicationRecord
  belongs_to :game
  belongs_to :player

  validates_presence_of :game, :player, :row, :column
  validates_numericality_of :column, greater_than_or_equal_to: 0, less_than: Game.board_size[0]
  validates_numericality_of :row, greater_than_or_equal_to: 0, less_than: Game.board_size[1]
  validates_uniqueness_of :player_id, scope: [:game_id, :row, :column]
end
