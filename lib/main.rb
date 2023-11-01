class Game
  attr_accessor :chessboard
  def initialize(board, player, piece)
    @board = board
    @player = player
    @piece = piece
    @round = 1
    @possible_moves = []
  end


  def play_game
    introduction
    @player.select_mode
    @board.display_board
    game_loop()

  end

  def game_loop
    loop do
      prompt_move
      @board.display_board
      @round += 1
      #return if win condition
    end
  end

  def player_turn
    if @round.odd? 
      "White"
    elsif @round.even?
      "Black"
    end
  end

  def prompt_move 
    puts "#{player_turn}: Select a piece"
    selection = prompt_valid_selection()
    @board.display_board
    
    puts "#{player_turn}: Select a position"
    p move = prompt_valid_move()
    @board.move_piece(selection, move)
    
  end

  # player input gets converted to array coordinates here
  def prompt_valid_selection
    loop do 
      chess_notation = @player.select_position
      p array_position = @board.select_piece(chess_notation)
      p @possible_moves = @piece.check_piece(array_position) # check what piece is being selected and return possible moves
      return array_position if @piece.friendly_piece?(array_position, @round)
      puts "\nInvalid, enter a piece with algebraic notation"
    end
  end

  def prompt_valid_move
    loop do
      chess_notation = @player.select_position
      p array_move = @board.select_piece(chess_notation)
       if @possible_moves.include?(array_move) && @piece.move_in_bounds?(array_move)
        @possible_moves = []
        return array_move
       end
      puts "\nInvalid, enter a move with algebraic notation"
    end
  end

  def introduction
    puts "Wecome to chess!"
    puts "\nHow to play:"
    puts "Using algebraic notation eg. d2"
    puts "1. Enter the position of the piece you want to select"
    puts "2. Enter where you want to move the piece"
    @board.display_board
    puts "\nSelect game mode:"
    puts "[1] Player vs Player"
    puts "[2] Player vs Computer"
  end

  # announcements
    # when king is in check?
    # pawn promotion prompt
    # Invalid 
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

    @display = []
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
    @display = []
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
    @chessboard[new_row][new_col] = @chessboard[old_row][old_col]
    @chessboard[old_row][old_col] = '   '
  end

  # display possible moves as red dots
  # highlight square of selected piece
  # refresh display when something happens?
end

class Piece

  def initialize(board)
    @board = board
    @chessboard = board.chessboard
  end

  # Don't let pieces go out of bounds (stay within array)
   # Pieces can be placed over enemy pieces / taking enemy piece

  def friendly_piece?(piece_coordinates, round)
    white = [' ♙ ', ' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ']
    black = [' ♟︎ ', ' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
    p row = piece_coordinates[0] 
    p col = piece_coordinates[1]
    p element = @chessboard[row][col]
    p round
    if round.odd? && white.include?(element)
      true
    elsif round.even? && black.include?(element)
      true
    else
      false
    end
  # Reuse? A friendly piece can't replace a friendly piece, use for not being able to move on top later
  end 

  # alternatively use this method to take out every possible move that's not in bounds instead of the input
  def move_in_bounds?(possible_moves)
    row = possible_moves[0] 
    col = possible_moves[1]
    if row.between?(0, 7) && col.between?(0, 7)
      true
    else
      false
    end
  end

  def check_piece(piece_coordinates)
    row = piece_coordinates[0] 
    col = piece_coordinates[1]
    #check what piece is being selected?
    if [' ♙ ', ' ♟︎ '].include?(@chessboard[row][col])
      possible_moves = pawn(piece_coordinates)
    elsif [' ♘ ', ' ♞ '].include?(@chessboard[row][col])
      possible_moves = knight(piece_coordinates)
    elsif [' ♗ ', ' ♝ '].include?(@chessboard[row][col])
      #possible_moves = bishop(piece_coordinates)
    elsif [' ♖ ', ' ♜ '].include?(@chessboard[row][col])
      #possible_moves = rook(piece_coordinates)
    elsif [' ♕ ', ' ♛ '].include?(@chessboard[row][col])
      #possible_moves = king(piece_coordinates)
    elsif [' ♔ ', ' ♚ '].include?(@chessboard[row][col])
      #possible_moves = queen(piece_coordinates)
    end
    possible_moves
  end

  def pawn(pawn_coordinates)
    #pawn_capture = [1, 1], [1, -1]
    row = pawn_coordinates[0] 
    col = pawn_coordinates[1]
    pawn_moves = pawn_first_move(pawn_coordinates)
    if @chessboard[row][col] == ' ♙ '
      possible_moves = pawn_moves.map do |move|
        [row + move[0], col + move[1]]
      end
    elsif @chessboard[row][col] == ' ♟︎ '
      possible_moves = pawn_moves.map do |move|
        [row - move[0], col - move[1]]
      end
    end
    possible_moves
  end

  # Return possible moves depending on pawn position
  def pawn_first_move(pawn_coordinates)
    row = pawn_coordinates[0] 
    col = pawn_coordinates[1]
    pawn_moves = []
  
    if row == 1 && @chessboard[row][col] == ' ♙ ' || row == 6 && @chessboard[row][col] == ' ♟︎ '
      pawn_moves = [[1, 0], [2, 0]]
    else
      pawn_moves = [[1, 0]]
    end
    pawn_moves
  end

  def en_passant
    # https://en.wikipedia.org/wiki/En_passant
  end

  def pawn_promotion
  end

  def knight(knight_coordinates)
    #pawn_capture = [1, 1], [1, -1]
    row = knight_coordinates[0] 
    col = knight_coordinates[1]
    knight_moves = [[2, 1], [1, 2], [2, -1], [1, -2], [-2, 1], [-1, 2], [-2, -1], [-1, -2]]
    if @chessboard[row][col] == ' ♘ '
      possible_moves = knight_moves.map do |move|
        [row + move[0], col + move[1]]
      end
    elsif @chessboard[row][col] == ' ♞ '
      possible_moves = knight_moves.map do |move|
        [row - move[0], col - move[1]]
      end
    end
    possible_moves
  end

  # increment base moves in loop until getting to end of board to get all possible moves
  # row/col intialized in loop resets it to base position for each move
  def bishop(bishop_coordinates)
    bishop_moves = []
    base_moves = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
    
    base_moves.each do |move|
      row = bishop_coordinates[0] 
      col = bishop_coordinates[1]
      7.times do
        row = row + move[0]
        col = col + move[1]
        if row.between?(0,7) && col.between?(0,7)
          bishop_moves << [row, col]
        else
          break
        end
      end
    end
    # save variable and keeping adding to it until it is between 0, 7
    # 1,1 start should give: [[2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [2, 0], [0, 0], [0, 2]]

    bishop_moves
  end

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


  def select_mode
    loop do
      mode = gets.chomp.to_i
      return mode if mode.between?(1,2)

      puts 'Enter 1 or 2 to select mode'
    end
    mode
  end

  
  # get move / handle invalid 
  # error message (not possible moves)
    # Out of bounds, can't move over friendly, moving king into check
end


class Serializer
  # Make game saveable by serializing with JSON
end

class Computer
  # build simple AI (random legal move, random piece, random location)
  # Select game mode
end

#board = Board.new
#piece = Piece.new(board)
#player = Player.new(board, piece)
#game = Game.new(board, player, piece)
#game.play_game



# General steps / Brainstorm
  # focus on single responsibility
  # Two players can play against each other or basic AI
  # Write tests for anything typed into command line repeatedly

# Check list
# pieces
  # check what piece is being selected
  # what direction pieces can move in
  # Don't let pieces move on friendly pieces
  # incoporate out of bounds into traversal array
  # attacking
# coloring board for selected piece movement
# learn how to refresh/clear console and update after every move
# valid move check
# edge cases
# win conditions
# simple ai / select game mode
# serializer


# other classes
# display class?
# movement / validate moves
  # edge cases, pawn promotion, en_passant, castling, 