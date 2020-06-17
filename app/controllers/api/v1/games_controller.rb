class Api::V1::GamesController < ApplicationController
  before_action :set_game, only: [:show, :attack]

  # GET /games
  def index
    @games = Game.all

    render json: @games
  end

  # GET /games/1
  def show
    render json: @game
  end

  # POST /games
  def create
    @game = Game.new(game_create_params)

    if @game.save
      render json: @game, status: :created
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # POST/PUT /games/1/attack
  def attack
    if @game.attack(coords[:x], coords[:y])
      game_move = GameMove.new game: @game, column: coords[:x], row: coords[:y]
      game_move.player_id = @game.player_one_id if @game.player_two_is_next?
      game_move.player_id = @game.player_two_id if @game.player_one_is_next?
      game_move.save

      @game.finish

      render :show
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id] ? params[:id] : params[:game_id])
  end

  def game_create_params
    params.require(:game).permit(:player_one_id, :player_two_id, :random_boards)
  end

  def coords
    params.require(:coords).permit(:x, :y)
  end
end
