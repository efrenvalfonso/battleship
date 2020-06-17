class Game < ApplicationRecord
  belongs_to :player_one, class_name: Player.name
  belongs_to :player_two, class_name: Player.name

  BOARD_CELL_STATES = [
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
  validates_inclusion_of :status, in: %w[placing_ships in_play finished]

  enum status: {placing_ships: 0, in_play: 1, finished: 2}

  alias_method :player_one_is_next?, :next_turn

  def initialize(attributes = nil)
    attributes = {} unless attributes
    attributes[:player_one_board] = default_board unless attributes[:player_one_board].present?
    attributes[:player_one_moves_board] = default_board unless attributes[:player_one_moves_board].present?
    attributes[:player_two_board] = default_board unless attributes[:player_two_board].present?
    attributes[:player_two_moves_board] = default_board unless attributes[:player_two_moves_board].present?

    super
  end

  def place_ship!(player, x, y, size, horizontal = true)
    if status.placing_ships?
      remaining_cells_field = "#{player.to_s}_remaining_cells"

      if send(remaining_cells_field) < Game.total_ships_space
        errors.add(:base, "The 'x' coordinate must be greater or equal than 0.") if x < 0
        errors.add(:base, "The 'x' coordinate must be less than #{Game.board_size[0]}.") if x >= Game.board_size[0]
        errors.add(:base, "The 'y' coordinate must be greater or equal than 0.") if y < 0
        errors.add(:base, "The 'y' coordinate must be less than #{Game.board_size[0]}.") if y >= Game.board_size[1]

        d = horizontal ? [1, 0] : [0, 1]

        size.times do |i|
          current_x, current_y = x + i * d[0], y + i * d[1]
          unless current_x < Game.board_size[0] &&
              current_y < Game.board_size[1] &&
              send("get_#{player}_board", current_x, current_y) == :empty
            errors.add(:base, 'This is an invalid position for that ship.')
            break
          end
        end

        if errors.empty?
          size.times do |i|
            send("set_#{player}_board", x + i * d[0], y + i * d[1], size)
          end

          save
        end
      else
        error.add(remaining_cells_field.to_sym, "bust be less than '#{Game.total_ships_space}'")
        false
      end
    else
      error.add(:status, "bust be 'placing_ships'")
      false
    end
  end

  def start!
    if !status.placing_ships?
      errors.add(:status, "must be 'placing_ships'")
      false
    elsif player_one_remaining_cells < Game.total_ships_space
      errors.add(:player_one_remaining_cells, "must be '#{Game.total_ships_space}'")
      false
    elsif player_one_remaining_cells < Game.total_ships_space
      errors.add(:player_two_remaining_cells, "must be '#{Game.total_ships_space}'")
      false
    else
      status.in_play!
      save
    end
  end

  def finish!
    if !status.in_play?
      errors.add(:status, "must be 'in_play'")
      false
    elsif player_one_remaining_cells > 0 && player_one_remaining_cells > 0
      errors.add(:player_one_remaining_cells, "must be '0'")
      errors.add(:player_two_remaining_cells, "must be '0'")
      false
    else
      status.finished!
      save
    end
  end

  def player_one_won?
    nil unless status.finished?
    player_one_remaining_cells == 0
  end

  def player_two_won?
    nil unless status.finished?
    player_two_remaining_cells == 0
  end

  # get and set for boards
  def method_missing(method, *args, &block)
    action, field = method.to_s.split('_', 2)
    x, y, value, _ = args

    if action.present? && field.present? && x.present? && y.present?
      case action
      when 'get'
        BOARD_CELL_STATES[send(field)[x * Game.board_size[0] + y].to_i]
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

  def self.total_ships_space
    15 # 1 + 2 + 3 + 4 + 5 (Patrol + Cruiser + Submarine + Battleship + Carrier)
  end


  private

  def default_board
    unless @default_board
      @default_board = ([0] * (Game.board_size[0] * Game.board_size[1])).join
    end

    @default_board
  end
end
