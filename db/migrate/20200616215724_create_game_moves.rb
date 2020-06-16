class CreateGameMoves < ActiveRecord::Migration[6.0]
  def change
    create_table :game_moves do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :row, limit: 1, null: false
      t.string :column, limit: 1, null: false

      t.timestamps

      t.index [:game_id, :player_id, :row, :column], unique: true
    end
  end
end
