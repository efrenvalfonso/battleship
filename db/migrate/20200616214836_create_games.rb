class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.references :player_one, null: false, foreign_key: {to_table: :players}
      t.string :player_one_board, limit: 100, null: false
      t.string :player_one_moves_board, limit: 100, null: false
      t.references :player_two, null: false, foreign_key: {to_table: :players}
      t.string :player_two_board, limit: 100, null: false
      t.string :player_two_moves_board, limit: 100, null: false
      t.boolean :next_turn, null: false, default: false
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps
    end
  end
end
