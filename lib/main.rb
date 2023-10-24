# General steps / Brainstorm
  # focus on single responsibility
  # Two players can play against each other or basic AI
  # Write tests for anything typed into command line repeatedly
  # Player 1 white piece goes first

# Psuedo Code:
class Game
  # Make game saveable by serializing with JSON
  # announce 
    # when king is in check
  # loop game functions
  # Play game
end

class Board
  # set up as array (8X8)
  def initialize
    @board = [
      [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ '],
      [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
      [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ ']
    ]
  end

  def display_board
    color_board
    row_count = 1

    puts '   a  b  c  d  e  f  g  h   '
    reverse_board = @board.reverse
    reverse_board.each do |row|
      # append 1 to 8 before and after each row
      row.unshift("#{row_count} ")
      row.push(" #{row_count}")
      row_count += 1

      puts row.join('')
      row.each do |element|
        if element != '   '
          element.prepend("\e[47m")
          element.concat("\e[0m")
        # prepend / append "\e[40m text \e[0m" to each element
        # 40 - 47
        # 47 gray
        # if not '   ' make black
        end
      end
    end
    puts '   a  b  c  d  e  f  g  h   '
  end

  def color_board
    @board.each_with_index do |row, index|
      if index.odd?
        row.each_with_index do |element, index|
          if index.odd?
            element.prepend("\e[47m")
            element.concat("\e[0m")
          else
            element.prepend("\e[46m")
            element.concat("\e[0m")
          end
        end
      else
        row.each_with_index do |element, index|
          if index.odd?
            element.prepend("\e[46m")
            element.concat("\e[0m")
          else
            element.prepend("\e[47m")
            element.concat("\e[0m")
          end

          # prepend / append "\e[40m  \e[0m" to each element "\e[31m●\e[0m"
          # if odd
            # element.prepend("e[40m")
            # element.concat()

          # 40 - 47
          # 47 gray
        end
      end
    end

  end


  # display possible moves as red dots
  # highlight square of selected piece
  # refresh display when something happens?
  # when piece moves, set empty square to '  '
end

class Piece
  # Don't let pieces go out of bounds (stay within array)
  # A friendly piece can't replace a friendly piece
  # Pieces can be placed over enemy pieces 
  # when pawn goes to opposite side prompt user
  # Basic Legal moves
  # multiply black moves by negative 1
  # only knight can go over pieces 
  # @Board [row] [Column]
    # Pawn
      # can move 1 row [x+1][y]
      # 2 in beginning
      # attack diagonally with [x+1][y+1] [x+1][y-1]
    # Knight
      # possible_moves = [[2, 1], [1, 2], [2, -1], [1, -2], [-2, 1], [-1, 2], [-2, -1], [-1, -2]]
    # Bishop
      # Diagonal lines: increments of [1,1] [-1,-1] [-1,1] [1, -1] or range?
    # Rook
      # move up and down [x+1..7][y+1..7]
      # Castling?
    # Queen
      # Combine the moves of rook and bishop
    # King
      # If king is in pathway of a piece declare check
      # If there is no path king can move from check, declare checkmate
      # Don't let king move into path of enemy piece
      # any direction by 1
      # Can't move king into a check
end

class Players
  # Select game mode
  # get move / handle invalid 
  # error message (not possible moves)
    # Out of bounds, can't move over friendly, moving king into check
  # select piece function
  # Convert A-h to array column numbers
  # -1 on row numbers to match array
  # Convert input to lowercase / case non sensitive
  # Switch D1(column + row) to 1D as board is represented as @Board[row][Column]
end

class Computer
  # build simple AI (random legal move, random piece, random location)
end


# other classes
# display class?
# movement / validate moves
# serializer

board = Board.new
board.display_board
# players = Players.new(board)
# game = Game.new(board, players)
# game.play_game