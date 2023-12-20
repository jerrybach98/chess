require 'json'
require_relative 'serializer'

# Handle player input
class Player
  attr_accessor :chessboard

  def set_instance(serializer)
    @serializer = serializer
  end

  def get_player_input
    loop do
      position = gets.chomp.downcase
      if valid_input?(position)
        return position
      elsif position == 'save'
        @serializer.save_game
      end

      puts "\nPlease enter a position using algebraic notation"
    end
    position
  end

  private

  # Check if algebraic notation is correct
  def valid_input?(position)
    array = position.split('')
    array[1] = array[1].to_i
    return true if array[0].match?(/[a-h]/) && array[1].between?(1, 8) && array.count == 2

    false
  end
end
