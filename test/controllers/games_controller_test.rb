require 'test_helper'

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:one)
  end

  test "should get index" do
    get games_url, as: :json
    assert_response :success
  end

  test "should create game" do
    assert_difference('Game.count') do
      post games_url, params: { game: { next_turn: @game.next_turn, player_one_board: @game.player_one_board, player_one_id: @game.player_one_id, player_one_moves_board: @game.player_one_moves_board, player_two_board: @game.player_two_board, player_two_id: @game.player_two_id, player_two_moves_board: @game.player_two_moves_board, status: @game.status } }, as: :json
    end

    assert_response 201
  end

  test "should show game" do
    get game_url(@game), as: :json
    assert_response :success
  end

  test "should update game" do
    patch game_url(@game), params: { game: { next_turn: @game.next_turn, player_one_board: @game.player_one_board, player_one_id: @game.player_one_id, player_one_moves_board: @game.player_one_moves_board, player_two_board: @game.player_two_board, player_two_id: @game.player_two_id, player_two_moves_board: @game.player_two_moves_board, status: @game.status } }, as: :json
    assert_response 200
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete game_url(@game), as: :json
    end

    assert_response 204
  end
end
