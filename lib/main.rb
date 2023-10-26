# General steps / Brainstorm
  # focus on single responsibility
  # Two players can play against each other or basic AI
  # Write tests for anything typed into command line repeatedly
  # Player 1 white piece goes first

# Psuedo Code:
class Game
  def initialize(board, players)
    @board = board
    @players = players
  end


  def play_game
    introduction
    @board.display_board

  end

  def game_loop
    play_game

  end

  def introduction
    puts "Wecome to chess!"
    puts "\nHow to play:"
    puts "Using algaebraic notation eg. d2"
    puts "1. Enter the position of the piece you want to select"
    puts "2. Enter where you want to move the piece"
    puts "\nSelect game mode:"
    puts "[1] Player vs Player"
    puts "[2] Player vs Computer"
  end

  # announcements
    # when king is in check?
  # game modes
  # player vs player
  # player vs computer
end

class Board
  def initialize
    @board = [
      [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
      [' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
      [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ '],
      
    ]
  end

  # Removes syntax from array, display horizontal and vertical coordinates
  def display_board
    color_board()

    row_count = 8
    puts '   a  b  c  d  e  f  g  h   '
    reverse_board = @board.reverse

    reverse_board.each do |row|
      row.unshift("#{row_count} ")
      row.push(" #{row_count}")
      row_count -= 1
      puts row.join('')
    end
    puts '   a  b  c  d  e  f  g  h   '
  end


  # Creates checkered pattern using indexes for alternating rows and column colors
  # 30 turns the pieces black, 47 background white, and 100 background grey
  def color_board
    @board.each_with_index do |row, index|
      if index.odd?
        row.each_with_index do |element, index|
          if index.odd?
            element.prepend("\e[30;47m")
            element.concat("\e[0m")
          else
            element.prepend("\e[30;100m")
            element.concat("\e[0m")
          end
        end
      else
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
  # pieces will have helper functions or method that stores movement
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
      # if king can't move anywhere stalemate
end

class Players
  def initialize(board)
    @board = board
    @player1 = nil
    @player2 = nil
  end

  def get_names
    puts 'Player 1 what is your name?'
    @player1 = gets.chomp
    puts 'Player 2 what is your name?'
    @player2 = gets.chomp
  end

  def select_position

  end




  # Select game mode
  # get move / handle invalid 
  # error message (not possible moves)
    # Out of bounds, can't move over friendly, moving king into check
  # select piece function
  # Convert A-h to array column numbers
  # -1 on row numbers to match array
  # Convert input to lowercase / case non sensitive
  # Switch D1(column + row) to 1D as board is represented as @Board[row][Column]
  # let players only be able to select their own piece
end


class Serializer
  # Make game saveable by serializing with JSON
end

class Computer
  # build simple AI (random legal move, random piece, random location)
end


# other classes
# display class?
# movement / validate moves
# serializer

board = Board.new
players = Players.new(board)
game = Game.new(board, players)
game.game_loop


# inputs
# what direction pieces can move in
# coloring board
# work on selecting pieces
# making them move
# learn how to refresh console and update after every move
# valid move check
# simple ai
# serializer