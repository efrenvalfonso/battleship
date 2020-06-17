class Game < ApplicationRecord
  belongs_to :player_one, class_name: Player.name
  belongs_to :player_two, class_name: Player.name

  BOARD_SIZE = [10, 10] # [width, height]
  SHIPS = [1, 2, 3, 4, 5]
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
  TOTAL_SHIPS_CELLS = SHIPS.sum

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
                      is: BOARD_SIZE[0] * BOARD_SIZE[1]
  validates_inclusion_of :next_turn, in: [true, false]
  validates_inclusion_of :status, in: %w[placing_ships in_play finished]

  enum status: {placing_ships: 0, in_play: 1, finished: 2}


  def initialize(attributes = nil)
    attributes = {} unless attributes

    if attributes[:random_boards]
      attributes[:player_one_board] = Game.random_board
      attributes[:player_two_board] = Game.random_board
      attributes[:player_one_remaining_cells] = TOTAL_SHIPS_CELLS
      attributes[:player_two_remaining_cells] = TOTAL_SHIPS_CELLS
      attributes[:status] = 1
    else
      attributes[:player_one_board] = default_board unless attributes[:player_one_board].present?
      attributes[:player_two_board] = default_board unless attributes[:player_two_board].present?
    end

    attributes.delete :random_boards
    attributes[:player_one_moves_board] = default_board unless attributes[:player_one_moves_board].present?
    attributes[:player_two_moves_board] = default_board unless attributes[:player_two_moves_board].present?

    super
  end

  def place_ship!(player, x, y, size, horizontal = true)
    if placing_ships?
      remaining_cells_field = "#{player.to_s}_remaining_cells"

      if send(remaining_cells_field) < TOTAL_SHIPS_CELLS
        errors.add(:base, "The 'x' coordinate must be greater or equal than 0.") if x < 0
        errors.add(:base, "The 'x' coordinate must be less than #{BOARD_SIZE[0]}.") if x >= BOARD_SIZE[0]
        errors.add(:base, "The 'y' coordinate must be greater or equal than 0.") if y < 0
        errors.add(:base, "The 'y' coordinate must be less than #{BOARD_SIZE[1]}.") if y >= BOARD_SIZE[1]

        d = horizontal ? [1, 0] : [0, 1]

        size.times do |i|
          current_x, current_y = x + i * d[0], y + i * d[1]
          unless current_x < BOARD_SIZE[0] &&
              current_y < BOARD_SIZE[1] &&
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
        error.add(remaining_cells_field.to_sym, "bust be less than '#{TOTAL_SHIPS_CELLS}'")
        false
      end
    else
      error.add(:status, "bust be 'placing_ships'")
      false
    end
  end

  def attack!(x, y)
    if in_play?
      attacking, receiving = player_one_is_next? ? [:player_one, :player_two] : [:player_two, :player_one]
      if send("get_#{attacking}_moves_board", x, y) == :empty
        if send("get_#{receiving}_board", x, y) == :empty
          send("set_#{attacking}_moves_board", x, y, :miss)
        else
          send("set_#{attacking}_moves_board", x, y, :hit)

          if player_one_is_next?
            self.player_two_remaining_cells -= 1
          else
            self.player_one_remaining_cells -= 1
          end
        end

        self.next_turn = !self.next_turn
        save
      else
        errors.add(:base, 'These coordinates were attacked previously.')
        false
      end
    else
      errors.add(:status, "must be 'in_play'")
      false
    end
  end

  def start!
    if !placing_ships?
      errors.add(:status, "must be 'placing_ships'")
      false
    elsif player_one_remaining_cells < TOTAL_SHIPS_CELLS
      errors.add(:player_one_remaining_cells, "must be '#{TOTAL_SHIPS_CELLS}'")
      false
    elsif player_one_remaining_cells < TOTAL_SHIPS_CELLS
      errors.add(:player_two_remaining_cells, "must be '#{TOTAL_SHIPS_CELLS}'")
      false
    else
      in_play!
      save
    end
  end

  def finish!
    if !in_play?
      errors.add(:status, "must be 'in_play'")
      false
    elsif player_one_remaining_cells > 0 && player_one_remaining_cells > 0
      errors.add(:player_one_remaining_cells, "must be '0'")
      errors.add(:player_two_remaining_cells, "must be '0'")
      false
    else
      self.finished!
      self.save
    end
  end

  def player_one_is_next?
    !next_turn
  end

  def player_two_is_next?
    next_turn
  end

  def player_one_won?
    nil unless finished?
    player_one_remaining_cells == 0
  end

  def player_two_won?
    nil unless finished?
    player_two_remaining_cells == 0
  end

  # get and set for boards
  def method_missing(method, *args, &block)
    action, field = method.to_s.split('_', 2)
    x, y, value, _ = args

    if action.present? && field.present? && x.present? && y.present?
      case action
      when 'get'
        BOARD_CELL_STATES[send(field)[x * BOARD_SIZE[0] + y].to_i]
      when 'set'
        if value.present?
          if value.is_a?(Symbol)
            value = BOARD_CELL_STATES.index(value)
          end
          send(field)[x * BOARD_SIZE[0] + y] = value.to_s
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
    BOARD_SIZE
  end

  def self.random_board
    # initialize an empty board
    rows = [nil] * BOARD_SIZE[1]
    columns = [nil] * BOARD_SIZE[0]

    rows.count.times do |i|
      rows[i] = '0' * BOARD_SIZE[0]
    end

    columns.count.times do |i|
      columns[i] = '0' * BOARD_SIZE[1]
    end

    # place each ship
    SHIPS.each do |ship|
      ship_str = ship.to_s
      ship_space = '0' * ship # available space that ship needs
      horizontal = rand(2) == 0
      lists_indexes = Array(0..((horizontal ? rows.count : columns.count) - 1)) # available row/column indexes
      i = -1
      available_positions = []

      # find positions from random rows/columns where the ship fits using KMP
      while available_positions.count == 0
        i = lists_indexes.delete_at(rand(lists_indexes.count)) # select a random row/column
        kmp = Kmp::String.new(horizontal ? rows[i] : columns[i]) # initialize KMP
        available_positions = kmp.match(ship_space) # check if there are available positions for ship
      end

      # select a random acailable position in row/column i
      start_position = available_positions.delete_at(rand(available_positions.count))

      # place the ship and update rows and columns
      ship.times do |k|
        j = start_position + k

        if horizontal
          rows[i][j] = ship_str
          columns[j][i] = ship_str
        else
          columns[i][j] = ship_str
          rows[j][i] = ship_str
        end
      end
    end

    # build the board by rows
    rows.join
  end


  private

  def default_board
    unless @default_board
      @default_board = '0' * (BOARD_SIZE[0] * BOARD_SIZE[1])
    end

    @default_board
  end
end
