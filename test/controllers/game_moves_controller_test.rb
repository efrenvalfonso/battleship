require 'test_helper'

class GameMovesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game_move = game_moves(:one)
  end

  test "should get index" do
    get game_moves_url, as: :json
    assert_response :success
  end

  test "should create game_move" do
    assert_difference('GameMove.count') do
      post game_moves_url, params: { game_move: { column: @game_move.column, game_id: @game_move.game_id, player_id: @game_move.player_id, row: @game_move.row } }, as: :json
    end

    assert_response 201
  end

  test "should show game_move" do
    get game_move_url(@game_move), as: :json
    assert_response :success
  end

  test "should update game_move" do
    patch game_move_url(@game_move), params: { game_move: { column: @game_move.column, game_id: @game_move.game_id, player_id: @game_move.player_id, row: @game_move.row } }, as: :json
    assert_response 200
  end

  test "should destroy game_move" do
    assert_difference('GameMove.count', -1) do
      delete game_move_url(@game_move), as: :json
    end

    assert_response 204
  end
end
