# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_16_215724) do

  create_table "game_moves", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "player_id", null: false
    t.integer "row", limit: 1, null: false
    t.string "column", limit: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id", "player_id", "row", "column"], name: "index_game_moves_on_game_id_and_player_id_and_row_and_column", unique: true
    t.index ["game_id"], name: "index_game_moves_on_game_id"
    t.index ["player_id"], name: "index_game_moves_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "player_one_id", null: false
    t.string "player_one_board", limit: 100, null: false
    t.string "player_one_moves_board", limit: 100, null: false
    t.integer "player_two_id", null: false
    t.string "player_two_board", limit: 100, null: false
    t.string "player_two_moves_board", limit: 100, null: false
    t.boolean "next_turn", null: false
    t.integer "status", limit: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_one_id"], name: "index_games_on_player_one_id"
    t.index ["player_two_id"], name: "index_games_on_player_two_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_players_on_name", unique: true
  end

  add_foreign_key "game_moves", "games"
  add_foreign_key "game_moves", "players"
  add_foreign_key "games", "player_ones"
  add_foreign_key "games", "player_twos"
end
