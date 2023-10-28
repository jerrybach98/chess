# General steps / Brainstorm
  # focus on single responsibility
  # Two players can play against each other or basic AI
  # Write tests for anything typed into command line repeatedly
  # Player 1 white piece goes first

# Psuedo Code:
class Game
  attr_accessor :chessboard
  def initialize(board, player, piece)
    @board = board
    @player = player
    @piece = piece
    @round = 1
  end


  def play_game
    introduction
    @player.select_mode
    @board.display_board

  end

  def game_loop
    loop do
      play_game
      prompt_move
      @board.display_board
      @round += 1
      return # until win condition?
    end
  end

  def prompt_move
    puts "Select a piece"
    player_input = @player.select_position
    p piece_coordinates = @board.select_piece(player_input)
    puts @piece.friendly_piece?(piece_coordinates, @round)
    @board.display_board
    
    puts "Select a position"
    player_input = @player.select_position
    move = @board.select_piece(player_input)
    @board.move_piece(piece_coordinates, move)
  end

  def introduction
    puts "Wecome to chess!"
    puts "\nHow to play:"
    puts "Using algebraic notation eg. d2"
    puts "1. Enter the position of the piece you want to select"
    puts "2. Enter where you want to move the piece"
    puts "\nSelect game mode:"
    puts "[1] Player vs Player"
    puts "[2] Player vs Computer"
  end

  # announcements
    # when king is in check?
    # pawn promotion prompt
  # game modes selection
    # player vs player
      # get both player names
    # player vs computer
      # get one player name

end

class Board
  attr_accessor :chessboard

  def initialize
    @chessboard = [
      [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
      [' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
      [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
    ]

    @display = nil
  end

  # Removes syntax from array, display horizontal and vertical coordinates
  # Print allows multiple strings on one line
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

    @display = nil
  end 

  # Makes colored clone of board for display purposes
  def colored_clone
    @display = Marshal.load(Marshal.dump(@chessboard))
    color_display
  end



  # Creates checkered pattern using indexes for alternating rows and column colors
  # 30 turns the pieces black, 47 background white, and 100 background grey
  def color_display
    @display.each_with_index do |row, index|
      if index.odd?
        odd_row_color(row)
      else
        even_row_color(row)
      end
    end
  end
  # Color board helper
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
  # Color board helper
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



  # Convert chess notation to array value [subtract 1][ASCII num]
  # Convert ASCII char to num using .ord
  def select_piece(position)
    array = position.split('').reverse
    row = array[0].to_i - 1
    col = array[1].ord - 97
    return row, col
  end

  def move_piece(piece, new_pos)
    # moves the selected piece to the new position
    # set the old position to empty 
    new_row = new_pos[0]
    new_col = new_pos[1]
    old_row = piece[0]
    old_col = piece[1]
    @chessboard[new_row][new_col] = @chessboard[old_row][old col]
    @chessboard[old_row][old_col] = '   '
  end

  # display possible moves as red dots
  # highlight square of selected piece
  # refresh display when something happens?
  # when piece moves, set empty square to '  '
end

class Piece

  def initialize(board)
    @board = board
    @chessboard = board.chessboard
  end

  # Don't let pieces go out of bounds (stay within array)
   # Pieces can be placed over enemy pieces / taking enemy piece
  # multiply black moves by negative 1?
  # pieces will have helper functions or method that stores movement

  def friendly_piece?(piece_coordinates, round)
    white = [' ♙ ', ' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ']
    black = [' ♟︎ ', ' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
    row = piece_coordinates[0] 
    col = piece_coordinates[1]
    p element = @chessboard[row][col]
    if round.odd? && white.include?(element)
      true
    elsif round.even? && black.include?(element)
      true
    else
      false
    end
  # A friendly piece can't replace a friendly piece, use for not being able to move on top later
  end 

  #def in_bounds?([x,y])
  #  if x.between?(0, 7) && y.between?(0, 7)
  #    true
  #  else
  #    false
  #  end
  #end

  #def pawn([x,y])


    # can move 1 row [x+1][y]
    # 2 in beginning
    # attack diagonally with [x+1][y+1] [x+1][y-1]
    # pawn promotion
  #end

  #def pawn_movement([x,y])
  #  puts new_pos = [x+1,y]
    # first_move = [x+2,y]

  #end

  #def pawn_moved? 
    #handle getting to enemy line?
    # if white pawn ==?
    # if black pawn ==?
  #  @board.each_with_index do |row, index|
  #    if index == 1 || index == 6
  #      true
  #    else
  #      false
  #    end
  #  end
  #end

  def en_passant
    # implement using round counter?
    # https://en.wikipedia.org/wiki/En_passant
  end

  def pawn_promotion
  
  end


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
      # Don't let king move into path of enemy piece or into check
      # any direction by 1
      # remove king from check by moving king, moving piece in way, or taking the piece
      # if king can't move anywhere stalemate
end

class Player
  def initialize(board, piece)
    @board = board
    @piece = piece
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
    loop do
      position = gets.chomp.downcase
      return position if valid_input?(position) # and friendly? == true

      puts 'Enter a position with algebraic notation'
    end
    position
  end

  # Helper function to check if algebraic notation is correct
  def valid_input?(position)
    array = position.split('')
    array[1] = array[1].to_i
    if array[0].match?(/[a-h]/) && array[1].between?(1, 8) && array.count == 2
      return true
    else
      return false
    end
  end

  #position = "c2"
  #p convert_position(position)

  def select_mode
    loop do
      mode = gets.chomp.to_i
      return mode if mode.between?(1,2)

      puts 'Enter 1 or 2 to select mode'
    end
    mode
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

#board = Board.new
#piece = Piece.new(board)
#player = Player.new(board, piece)
#game = Game.new(board, player, piece)
#game.game_loop


# Check list
# rename chessboard instance variable for clarity / select firendly pieces only

# select valid piece / 
  # if turn odd can only select white
  # if turn even select black
# pieces
  # what direction pieces can move in
  # Valid piece move
# coloring board for selected piece movement
# learn how to refresh console and update after every move
# valid move check
# edge cases
# win conditions
# simple ai / select game mode
# serializer


# other classes
# display class?
# movement / validate moves