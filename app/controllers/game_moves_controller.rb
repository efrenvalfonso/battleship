class GameMovesController < ApplicationController
  before_action :set_game_move, only: [:show, :update, :destroy]

  # GET /game_moves
  def index
    @game_moves = GameMove.all

    render json: @game_moves
  end

  # GET /game_moves/1
  def show
    render json: @game_move
  end

  # POST /game_moves
  def create
    @game_move = GameMove.new(game_move_params)

    if @game_move.save
      render json: @game_move, status: :created, location: @game_move
    else
      render json: @game_move.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /game_moves/1
  def update
    if @game_move.update(game_move_params)
      render json: @game_move
    else
      render json: @game_move.errors, status: :unprocessable_entity
    end
  end

  # DELETE /game_moves/1
  def destroy
    @game_move.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_move
      @game_move = GameMove.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def game_move_params
      params.require(:game_move).permit(:game_id, :player_id, :row, :column)
    end
end
