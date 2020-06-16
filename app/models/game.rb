class Game < ApplicationRecord
  belongs_to :player_one
  belongs_to :player_two
end
