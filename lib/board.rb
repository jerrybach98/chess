require 'json'

# Handles board visualization and logic
class Board
  attr_accessor :chessboard, :display

  def initialize
    @chessboard = [
      [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
      [' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♟ ', ' ♟ ', ' ♟ ', ' ♟ ', ' ♟ ', ' ♟ ', ' ♟ ', ' ♟ '],
      [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
    ]

    @display = []
  end

  # Array index of every position
  def board_indexes
    row = 0
    col = 0
    board_indexes = []

    until row == 8
      8.times do
        board_indexes << [row, col]
        col += 1
      end
      row += 1
      col = 0
    end
    board_indexes
  end

  # Removes syntax from array, display horizontal and vertical coordinate. Use print to allow multiple strings on one line
  def display_board
    colored_clone
    row_count = 8

    puts '   a  b  c  d  e  f  g  h   '
    reverse_board = @display.reverse
    reverse_board.each do |row|
      print "#{row_count} "
      print row.join('')
      print " #{row_count}"
      puts  "\n"
      row_count -= 1
    end
    puts '   a  b  c  d  e  f  g  h   '
    @display = []
  end

  # Prints board to top left of console
  def reset_board_display
    print "\e[2J\e[H"
    display_board
  end

  # Reverse chess notation string, convert chess notation number to array value (row), and convert ASCII char to num using .ord (col)
  def select_piece(position)
    array = position.split('').reverse
    row = array[0].to_i - 1
    col = array[1].ord - 97
    [row, col]
  end

  # Update board by moving a piece and setting old position to empty
  def move_piece(piece, new_pos)
    new_row = new_pos[0]
    new_col = new_pos[1]
    old_row = piece[0]
    old_col = piece[1]
    @chessboard[new_row][new_col] = @chessboard[old_row][old_col]
    @chessboard[old_row][old_col] = '   '
  end

  private

  # Makes clone of board for colored display purposes
  def colored_clone
    @display = Marshal.load(Marshal.dump(@chessboard))
    color_display
  end

  # Creates checkered pattern using indexes for alternating rows and column colors
  def color_display
    @display.each_with_index do |row, index|
      if index.odd?
        odd_row_color(row)
      else
        even_row_color(row)
      end
    end
  end

  # Helper function to add ANSI color codes to strings to display color
  # 30: black texts/pieces, 47: white background, 100: grey background
  def odd_row_color(row)
    row.each_with_index do |element, index|
      if index.odd?
        element.prepend("\e[30;47m")
        element.concat("\e[0m")
      else
        element.prepend("\e[30;100m")
        element.concat("\e[0m")
      end
    end
  end

  def even_row_color(row)
    row.each_with_index do |element, index|
      if index.odd?
        element.prepend("\e[30;100m")
        element.concat("\e[0m")
      else
        element.prepend("\e[30;47m")
        element.concat("\e[0m")
      end
    end
  end
end
