class Game
  attr_accessor :chessboard, :round
  def initialize(board, player, piece)
    @board = board
    @chessboard = board.chessboard
    @player = player
    @piece = piece
    @round = 1
    @possible_moves = []
    @notation_moves = [] # for faster testing
    @white_moves = []
    @black_moves = []
  end

  # Show notation For faster puts testing
  def algebraic_possible_moves(moves)
    if moves == nil 
      return 
    else
      new_moves = moves.map do |move|
        array = move.reverse
        row = (array[0] + 97).chr
        col = (array[1] + 1).to_s
        notation = [row, col] * ""
      end
    end
    new_moves
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
      #indexes = @board.board_indexes
      #p algebraic_possible_moves(white_attacks(indexes))
      chess_notation = @player.select_position
      p array_position = @board.select_piece(chess_notation)
      p @possible_moves = @piece.check_piece(array_position, @round) # check what piece is being selected and return possible moves
      p @notation_moves = algebraic_possible_moves(@possible_moves)
      # if possible moves.empty? when selecting, deselect the piece
      return array_position if @piece.friendly_piece?(array_position, @round) && @possible_moves.any?
      puts "\nInvalid selection, enter a valid piece with algebraic notation"
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

  def white_attacks(indexes)
    white = [' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ']
    pawn = [' ♙ ']

    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      if white.include?(element)
        @white_moves.concat(@piece.check_piece(index, @round))
      elsif pawn.include?(element)
        @white_moves.concat(@piece.pawn_attacks(index, @round))
      end
    end
      # return coordinates of every board
      # each do, run coordinates through check_piece method
      # add possible moves 

    # repeat for pawn but dirrectly call pawn_attack
    @white_moves
  end

end

class Board
  attr_accessor :chessboard

  def initialize
    @chessboard = [
      [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
      [' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
      ['   ', '   ', '   ', ' ♟︎ ', '   ', ' ♟︎ ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
      [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
    ]

    @display = []
  end

  # returns index of every possible board position
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
  # Add ANSI color codes to string to display color
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

end

class Piece
  attr_accessor :round

  def initialize(board)
    @board = board
    @chessboard = board.chessboard
  end

  # Used to identify that the correct colored piece is being selected
  # Also used in possible move generation 
  def friendly_piece?(piece_coordinates, round)
    white = [' ♙ ', ' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ']
    black = [' ♟︎ ', ' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
    row = piece_coordinates[0] 
    col = piece_coordinates[1]
    element = @chessboard[row][col]
    round
    if round.odd? && white.include?(element)
      true
    elsif round.even? && black.include?(element)
      true
    else
      false
    end
  end 

  def enemy_piece?(piece_coordinates, round)
    white = [' ♙ ', ' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ']
    black = [' ♟︎ ', ' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
    row = piece_coordinates[0] 
    col = piece_coordinates[1]
    element = @chessboard[row][col]
    if round.even? && white.include?(element)
      true
    elsif round.odd? && black.include?(element)
      true
    else
      false
    end
  end 

  def move_in_bounds?(possible_moves)
    row = possible_moves[0] 
    col = possible_moves[1]
    if row.between?(0, 7) && col.between?(0, 7)
      true
    else
      false
    end
  end

  def check_piece(piece_coordinates, round)
    row = piece_coordinates[0] 
    col = piece_coordinates[1]
    #check what piece is being selected?
    if [' ♙ ', ' ♟︎ '].include?(@chessboard[row][col])
      possible_moves = pawn(piece_coordinates, round)
    elsif [' ♘ ', ' ♞ '].include?(@chessboard[row][col])
      possible_moves = knight(piece_coordinates, round)
    elsif [' ♗ ', ' ♝ '].include?(@chessboard[row][col])
      possible_moves = bishop(piece_coordinates, round)
    elsif [' ♖ ', ' ♜ '].include?(@chessboard[row][col])
      possible_moves = rook(piece_coordinates, round)
    elsif [' ♕ ', ' ♛ '].include?(@chessboard[row][col])
      possible_moves = queen(piece_coordinates, round)
    elsif [' ♔ ', ' ♚ '].include?(@chessboard[row][col])
      possible_moves = king(piece_coordinates, round)
    end
    possible_moves
  end

  # Concat vertical movement and diagonal movement separately as they require different conditions
  def pawn(pawn_coordinates, round)
    row = pawn_coordinates[0] 
    col = pawn_coordinates[1]
    pawn_moves = []

    attacks = pawn_attacks(pawn_coordinates, round)
    base_moves = pawn_first_move(pawn_coordinates)
    pawn_moves.concat(pawn_attack_range(attacks, round))

    base_moves.map do |move|
      possible_move = [row + move[0], col + move[1]]
      if move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == false && enemy_piece?(possible_move, round) == false 
        pawn_moves << possible_move
      end
    end

    pawn_moves
  end

  # Creates list of possible pawn attack movement
  def pawn_attacks(pawn_coordinates, round)
    row = pawn_coordinates[0] 
    col = pawn_coordinates[1]
    attack_coordinates = []

    attacks = [[row+1, col+1], [row+1, col-1], [row-1, col+1], [row-1, col-1]]

    attacks.map do |attack|
      if move_in_bounds?(attack) && friendly_piece?(attack, round) == false #&& enemy_piece?(attack, round) == true
        attack_coordinates << attack
      end
    end
    attack_coordinates
  end

  # check if enemy units are in pawn attack coordinates
  def pawn_attack_range(attacks, round)
    diagonal_attacks = []

    attacks.each do |attack|
      if enemy_piece?(attack, round) == true
        diagonal_attacks << attack
      end
    end
    diagonal_attacks
  end

  # Helper function to return possible pawn moves depending on pawn position
  # Pawn can only move two squares if it's first move and there is nothing blocking it's path
  def pawn_first_move(pawn_coordinates)
    row = pawn_coordinates[0] 
    col = pawn_coordinates[1]
    pawn_moves = []
  
    if row == 1 && @chessboard[row][col] == ' ♙ ' && @chessboard[row+1][col] == '   '
      pawn_moves = [[1, 0], [2, 0]]
    elsif row != 1 && @chessboard[row][col] == ' ♙ '
      pawn_moves = [[1, 0]]
    elsif row == 6 && @chessboard[row][col] == ' ♟︎ ' && @chessboard[row-1][col] == '   '
      pawn_moves = [[-1, 0], [-2, 0]]
    elsif row != 6 && @chessboard[row][col] == ' ♟︎ ' 
      pawn_moves = [[-1, 0]]
    end
    pawn_moves
  end

  def en_passant
    # https://en.wikipedia.org/wiki/En_passant
  end

  def pawn_promotion
  end

  #def not_friendly?(possible_move)
  #  row = knight_coordinates[0] 
  #  col = knight_coordinates[1]
  #  if @chessboard[row][col] == 
    # return true if it sits on a friendly piece with round count
    # return false
 #   end
 # end

  # figure out how to pass round instance variable to piece class
  def knight(knight_coordinates, round)
    #pawn_capture = [1, 1], [1, -1]
    row = knight_coordinates[0] 
    col = knight_coordinates[1]
    base_moves = [[2, 1], [1, 2], [2, -1], [1, -2], [-2, 1], [-1, 2], [-2, -1], [-1, -2]]
    knight_moves = []

      base_moves.each do |move|
        possible_move = [row + move[0], col + move[1]]
        if move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == false
          knight_moves << possible_move
        end
      end
    knight_moves
  end

  # increment base moves in loop until getting to end of board to get all possible moves
  # row/col intialized in loop resets it to base position for each move
  def bishop(bishop_coordinates, round)
    base_moves = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
    bishop_moves = []
    
    base_moves.each do |move|
      bishop_moves.concat(line_traversal(move, bishop_coordinates, round))
    end
    bishop_moves
  end

  def rook(rook_coordinates, round)
    base_moves = [[1, 0], [-1, 0], [0, -1], [0, 1]]
    rook_moves = []
    
    base_moves.each do |move|
      rook_moves.concat(line_traversal(move, rook_coordinates, round))
    end
    rook_moves
  end

  def castling
    #squares between king and rook are vacant
    # use a flag if king or rook has moved from their original position?
  end

  def queen(queen_coordinates, round)
    base_moves = [[1, 1], [1, -1], [-1, -1], [-1, 1], [1, 0], [-1, 0], [0, -1], [0, 1]]
    queen_moves = []
    
    base_moves.each do |move|
      queen_moves.concat(line_traversal(move, queen_coordinates, round))
    end
    queen_moves
  end

  # Helper function to increment position by base move to move through array in a line
  # Stop generation once on enemy piece but include first one
  def line_traversal(move, coordinates, round)
    moves = []
    row = coordinates[0] 
    col = coordinates[1]
    7.times do
      row = row + move[0]
      col = col + move[1]
      new_move = [row, col]
      if move_in_bounds?(new_move) && friendly_piece?(new_move, round) == false && enemy_piece?(new_move, round) == false
        moves << new_move
      elsif move_in_bounds?(new_move) && enemy_piece?(new_move, round)
        moves << new_move
        break
      else
        break
      end
    end
    moves
  end

  def king(knight_coordinates, round)
    row = knight_coordinates[0] 
    col = knight_coordinates[1]
    base_moves = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
    king_moves = []

    base_moves.each do |move|
      possible_move = [row + move[0], col + move[1]]
      if move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == false
        king_moves << possible_move
      end
    end
    king_moves
  end

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

end


class Serializer
  # Make game saveable by serializing with JSON
end

class Computer
  # build simple AI (random legal move, random piece, random location)
  # Select game mode
end

board = Board.new
piece = Piece.new(board)
player = Player.new(board, piece)
game = Game.new(board, player, piece)
game.play_game



# General steps / Brainstorm
  # focus on single responsibility
  # Two players can play against each other or basic AI
  # Write tests for anything typed into command line repeatedly

# psuedo
# pieces

# win conditions
  #check for chceck after each move
    # store value of every possible white moves and every black moves
      # 2 instance variables, black and white
      # use the chess board
      # breakdown chess board into array posiitions
        # if white_piece, add array coordinates
      # each do loop () through coordinates
      # << each possible move
      # check if it works with pawn

    # Don't let king move itself into a check (remove any possible moves if it matches from all possible enemy moves)
    # Don't let piece move if it put's king into check
      # Implementation?
    # force king to move if in check or block/capture
    # checkmate if king can't move/block/capture

# edge cases
  # stalemate if king can't move anywhere / draw
  # pawn promotion / prompt
  # castling, use flags / prompt
    # add rook to possible move list? if flag
    # select / king / select castle
    # rook next to king starting position / king on outside
    # all rows empty
  # en passant


# coloring board for selected piece movement
  # display possible moves as red dots
  # highlight square of selected piece
# learn how to refresh/clear console and update after every move
# simple ai / select game mode
  # player vs player
  # player vs computer
# serializer


# other classes
# display class?
# movement / validate moves
  # edge cases, pawn promotion, en_passant, castling, 