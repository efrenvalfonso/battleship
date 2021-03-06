class Api::V1::PlayersController < ApplicationController
  before_action :set_player, only: [:show, :update, :destroy]

  # GET /players
  def index
    @players = Player.all
  end

  # GET /players/1
  def show; end

  # POST /players
  def create
    @player = Player.new(player_params)

    if @player.save
      render :show, status: :created
    else
      render json: @player.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /players/1
  def update
    if @player.update(player_params)
      render :show
    else
      render json: @player.errors, status: :unprocessable_entity
    end
  end

  # DELETE /players/1
  def destroy
    @player.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Sanitizing params. Only allow a trusted parameter "white list" through.
    def player_params
      params.require(:player).permit(:name)
    end
end
