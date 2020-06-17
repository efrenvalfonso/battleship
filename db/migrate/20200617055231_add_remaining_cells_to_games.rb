class AddRemainingCellsToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :player_one_remaining_cells, :integer, null: false, default: 0
    add_column :games, :player_two_remaining_cells, :integer, null: false, default: 0
  end
end
