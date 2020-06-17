class Game < ApplicationRecord
  belongs_to :player_one, class_name: Player.name
  belongs_to :player_two, class_name: Player.name

  BOARD_SIZE = [10, 10] # [width, height]
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

  # get and set for boards
  def method_missing(method, *args, &block)
    action, field = method.to_s.split('_', 2)
    x, y, value, _ = args

    if action.present? && field.present? && x.present? && y.present?
      case action
      when 'get'
        BOARD_SIZE[send(field)[x * BOARD_SIZE[0] + y].to_i]
      when 'set'
        if value.present?
          if value.is_a?(Symbol)
            value = BOARD_STATES.index(value)
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
end
