class Game < ApplicationRecord
  belongs_to :player_one, class_name: Player.name
  belongs_to :player_two, class_name: Player.name
end
