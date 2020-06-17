class Game < ApplicationRecord
  belongs_to :player_one, class_name: Player.name
  belongs_to :player_two, class_name: Player.name

  BOARD_STATES = [
      :empty, # 0
      # board states
      :patrol, # 1
      :cruiser, # 2
      :submarine, # 3
      :battleship, # 4
      :carrier, # 5
      # moves board states
      :miss, # 6
      :hit, # 7
      :sink # 8
  ]

  validates_presence_of :player_one,
                        :player_one_board,
                        :player_one_moves_board,
                        :player_two,
                        :player_two_board,
                        :player_two_moves_board,
                        :status
  validates_length_of :player_one_board,
                      :player_one_moves_board,
                      :player_two_board,
                      :player_two_moves_board,
                      is: Game.board_size[0] * Game.board_size[1]
  validates_inclusion_of :next_turn, in: [true, false]
  validates_inclusion_of :status, in: %w[in_play player_one_won player_two_won]

  enum status: {in_play: 0, player_one_won: 1, player_two_won: 2}

  alias_method :player_one_is_next?, :next_turn

  def initialize(attributes = nil)
    attributes = {} unless attributes
    attributes[:player_one_board] = default_board unless attributes[:player_one_board].present?
    attributes[:player_one_moves_board] = default_board unless attributes[:player_one_moves_board].present?
    attributes[:player_two_board] = default_board unless attributes[:player_two_board].present?
    attributes[:player_two_moves_board] = default_board unless attributes[:player_two_moves_board].present?

    super
  end

  # get and set for boards
  def method_missing(method, *args, &block)
    action, field = method.to_s.split('_', 2)
    x, y, value, _ = args

    if action.present? && field.present? && x.present? && y.present?
      case action
      when 'get'
        Game.board_size[send(field)[x * Game.board_size[0] + y].to_i]
      when 'set'
        if value.present?
          if value.is_a?(Symbol)
            value = BOARD_STATES.index(value)
          end
          send(field)[x * Game.board_size[0] + y] = value.to_s
        else
          super(method, *args, &block)
        end
      else
        super(method, *args, &block)
      end
    else
      super
    end
  end

  def self.board_size
    [10, 10] # [width, height]
  end


  private

  def default_board
    unless @default_board
      @default_board = ([0] * (Game.board_size[0] * Game.board_size[1])).join
    end

    @default_board
  end
end
