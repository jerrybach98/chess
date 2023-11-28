class Game
  attr_accessor :round
  def initialize(board, player, piece)
    @board = board
    @chessboard = board.chessboard
    @player = player
    @piece = piece
    @round = 1
    @selected_possible_moves = []
    @notation_moves = [] # for faster testing
    @white_attacks = []
    @black_attacks = []
    @all_white_moves = []
    @all_black_moves = []
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
    #return color win announcement
  end

  def debug_announcements
    puts "Black Pin line: #{@piece.black_pins}"
    puts "White Pin line: #{@piece.white_pins}"
    puts "Black Check line: #{@piece.black_checks.uniq}"
    puts "White Check line: #{@piece.white_checks.uniq}"
    puts "King Black Check line: #{@piece.king_black_checks.flatten(1).uniq}"
    puts "King White Check line: #{@piece.king_white_checks.flatten(1).uniq}"
    puts "Black Protected Piece: #{algebraic_possible_moves(@piece.black_protected)}"
    puts "White Protected Piece: #{algebraic_possible_moves(@piece.white_protected)}"
  end


  def game_loop
    loop do
      reset_game_state()
      all_possible_attacks()
      debug_announcements()
      checkmate?()
      prompt_move()
      checkmate?()
      @board.display_board
      @round += 1
      reset_game_state()
      all_possible_attacks()
      #check win condition
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
      array_position = @board.select_piece(chess_notation)
      @selected_possible_moves = @piece.check_piece(array_position, @round, @black_attacks, @white_attacks) # check what piece is being selected and return possible moves
      @notation_moves = algebraic_possible_moves(@selected_possible_moves)
      puts "Possible Moves: #{@notation_moves}"
      # if possible moves.empty? when selecting, deselect the piece
      return array_position if @piece.friendly_piece?(array_position, @round) && @selected_possible_moves.any?
      puts "\nInvalid selection, enter a valid piece with algebraic notation"
      rescue NoMethodError
      puts "\nInvalid selection, enter a valid piece with algebraic notation"
    end
  end

  def prompt_valid_move
    loop do
      chess_notation = @player.select_position
      p array_move = @board.select_piece(chess_notation)
       if @selected_possible_moves.include?(array_move) && @piece.move_in_bounds?(array_move)
        p "Round number: #{@round}"
        return array_move
       end
      puts "\nInvalid, enter a move with algebraic notation"
      rescue NoMethodError
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

  # Switch round variable to influence round logic allowing generation of moves on enemy pieces and friendly protected pieces
  # Pawn attacks are edge cases since they attack different from traversal
  def white_attacks(indexes)
    white = [' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ']
    pawn = [' ♙ ']
    
    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      if white.include?(element)
        @white_attacks.concat(@piece.check_piece(index, 1, @black_attacks, @white_attacks))
      elsif pawn.include?(element)
        @white_attacks.concat(@piece.pawn_attacks(index, 1))
      end
    end

    # add @piece.white_protected to white_attacks

    moves = @white_attacks.uniq
  end


  def black_attacks(indexes)
    black = [' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
    pawn = [' ♟ ']
    
    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      if black.include?(element)
        @black_attacks.concat(@piece.check_piece(index, 2, @black_attacks, @white_attacks))
      elsif pawn.include?(element)
        @black_attacks.concat(@piece.pawn_attacks(index, 2))
      end
    end

    moves = @black_attacks.uniq
  end

  # shows all possible attacks on empty spaces, enemy units, and protected pieces so that King can't move over them
  def all_possible_attacks
    indexes = @board.board_indexes
    white = algebraic_possible_moves(white_attacks(indexes))
    black = algebraic_possible_moves(black_attacks(indexes))
    puts "White Attacks #{white}"
    puts "Black Attacks #{black}"
  end

  def checkmate?
    indexes = @board.board_indexes
    white = algebraic_possible_moves(generate_white_moves(indexes))
    black = algebraic_possible_moves(generate_black_moves(indexes))
    puts "White moves for check: #{white}"
    puts "Black moves for check: #{black}"
  end

  def generate_white_moves(indexes)
    white = [' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ', ' ♙ ']

    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      if white.include?(element)
        @all_white_moves.concat(@piece.check_piece(index, 1, @black_attacks, @all_white_moves))
      end
    end
  @all_white_moves
  end

  def generate_black_moves(indexes)
    black = [' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
    pawn = [' ♟ ']

    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      if black.include?(element)
        @all_black_moves.concat(@piece.check_piece(index, 2, @all_black_moves, @white_attacks))
      elsif pawn.include?(element)
        @all_black_moves.concat(@piece.pawn_attacks(index, 2))
      end
    end

    @all_black_moves
  end

  def reset_game_state
    @selected_possible_moves = []
    @white_attacks = []
    @black_attacks = []
    @piece.white_pins = {}
    @piece.black_pins = {}
    @piece.white_checks = []
    @piece.black_checks = []
    @piece.king_white_checks = []
    @piece.king_black_checks = []
    @all_white_moves = []
    @all_black_moves = []
    # @piece.white_protected
  end
end

class Board
  attr_accessor :chessboard

  def initialize
    @chessboard = [
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♖ ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♖ ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', ' ♚ ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', ' ♞ ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', ' ♔ ', ' ♜ ']
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

# put accessor in class if you want to access it in a different one
class Piece
  attr_accessor :black_pins, :white_pins, :black_checks, :white_checks, :king_white_checks, :king_black_checks, :black_protected, :white_protected

  def initialize(board)
    @board = board
    @chessboard = board.chessboard
    @white_pins = {}
    @black_pins = {}
    # Depending on how I handle array it might not work for double checks
    @white_checks = []
    @black_checks = []

    @king_white_checks = []
    @king_black_checks = []
    @black_protected = []
    @white_protected = []
  end

  # Used to identify that the correct colored piece is being selected
  # Also used in possible move generation 
  # Returns false if not friendly or blank square
  def friendly_piece?(piece_coordinates, round)
    white = [' ♙ ', ' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ']
    black = [' ♟ ', ' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
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
    black = [' ♟ ', ' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
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

  def double_check?(round)
    if round.odd? && @black_checks.uniq.count == 2
      true
    elsif round.even? && @white_checks.uniq.count == 2
      true
    else
      false
    end
  end

  def check_piece(piece_coordinates, round, black_attacks, white_attacks)
    row = piece_coordinates[0] 
    col = piece_coordinates[1]
    #check what piece is being selected?
    if [' ♙ ', ' ♟ '].include?(@chessboard[row][col])
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
      possible_moves = king(piece_coordinates, round, black_attacks, white_attacks)
    end
    possible_moves
  end

  # Concat vertical movement and diagonal movement separately as they require different conditions
  def pawn(pawn_coordinates, round)
    row = pawn_coordinates[0] 
    col = pawn_coordinates[1]
    pawn_moves = []
    base_moves = pawn_first_move(pawn_coordinates)

    attacks = pawn_attacks(pawn_coordinates, round)
    pawn_moves.concat(pawn_attack_range(attacks, round))

    base_moves.map do |move|
      possible_move = [row + move[0], col + move[1]]
      if move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == false && enemy_piece?(possible_move, round) == false && double_check?(round) == false
        pawn_moves << possible_move
        pawn_moves = pinned_moves(pawn_coordinates, pawn_moves, round)
        pawn_moves = friendly_moves_in_check(pawn_coordinates, pawn_moves, round)
      end
    end

    pawn_moves
  end

  # Creates list of possible pawn attack movement
  def pawn_attacks(pawn_coordinates, round)
    row = pawn_coordinates[0] 
    col = pawn_coordinates[1]
    attack_coordinates = []

    if @chessboard[row][col] == ' ♙ '
      attacks = [[1, 1], [1, -1]]
    elsif @chessboard[row][col] == ' ♟ '
      attacks = [[-1, 1], [-1, -1]]
    end

    attacks.map do |move|
      #puts "Checking attack[#{row+move[0]}][#{col+ move[1]}]: #{@chessboard[row + move[0]][col + move[1]]}"
      possible_attack = [row + move[0], col + move[1]]
      if move_in_bounds?(possible_attack) && friendly_piece?(possible_attack, round) == false 
        attack_coordinates << possible_attack
        generate_check(move, pawn_coordinates, round)
        generate_protected_positions(move, pawn_coordinates, round)
      elsif move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == true
        generate_protected_positions(move, pawn_coordinates, round)
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
    elsif row == 6 && @chessboard[row][col] == ' ♟ ' && @chessboard[row-1][col] == '   '
      pawn_moves = [[-1, 0], [-2, 0]]
    elsif row != 6 && @chessboard[row][col] == ' ♟ ' 
      pawn_moves = [[-1, 0]]
    end
    pawn_moves
  end

  def en_passant
    # https://en.wikipedia.org/wiki/En_passant
  end

  def pawn_promotion
  end

  def knight(knight_coordinates, round)
    row = knight_coordinates[0] 
    col = knight_coordinates[1]
    base_moves = [[2, 1], [1, 2], [2, -1], [1, -2], [-2, 1], [-1, 2], [-2, -1], [-1, -2]]
    knight_moves = []

    base_moves.each do |move|
      possible_move = [row + move[0], col + move[1]]
      if move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == false && double_check?(round) == false
        knight_moves << possible_move
        generate_check(move, knight_coordinates, round)
        knight_moves = pinned_moves(knight_coordinates, knight_moves, round)
        knight_moves = friendly_moves_in_check(knight_coordinates, knight_moves, round)
      elsif move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == true
        generate_protected_positions(move, knight_coordinates, round)
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
      pins(move, bishop_coordinates, round)
      generate_check(move, bishop_coordinates, round)
      generate_protected_positions(move, bishop_coordinates, round)
      bishop_moves = pinned_moves(bishop_coordinates, bishop_moves, round)
      bishop_moves = friendly_moves_in_check(bishop_coordinates, bishop_moves, round)
    end
    bishop_moves
  end

  def rook(rook_coordinates, round)
    base_moves = [[1, 0], [-1, 0], [0, -1], [0, 1]]
    rook_moves = []
    
    base_moves.each do |move|
      rook_moves.concat(line_traversal(move, rook_coordinates, round))
      pins(move, rook_coordinates, round)
      generate_check(move, rook_coordinates, round)
      generate_protected_positions(move, rook_coordinates, round)
      rook_moves = pinned_moves(rook_coordinates, rook_moves, round)
      rook_moves = friendly_moves_in_check(rook_coordinates, rook_moves, round)
    end
    rook_moves
  end

  def queen(queen_coordinates, round)
    base_moves = [[1, 1], [1, -1], [-1, -1], [-1, 1], [1, 0], [-1, 0], [0, -1], [0, 1]]
    queen_moves = []
    
    base_moves.each do |move|
      queen_moves.concat(line_traversal(move, queen_coordinates, round))
      pins(move, queen_coordinates, round)
      generate_check(move, queen_coordinates, round)
      generate_protected_positions(move, queen_coordinates, round)
      queen_moves = pinned_moves(queen_coordinates, queen_moves, round)
      queen_moves = friendly_moves_in_check(queen_coordinates, queen_moves, round)
    end
    queen_moves
  end

  # Helper function to increment position by base move to move through array in a line
  # first condition only moves on blanks
  # Break generation once possible move traverses over the first enemy piece
  def line_traversal(move, coordinates, round)
    moves = []
    row = coordinates[0] 
    col = coordinates[1]
    7.times do
      row = row + move[0]
      col = col + move[1]
      new_move = [row, col]
      if move_in_bounds?(new_move) && friendly_piece?(new_move, round) == false && enemy_piece?(new_move, round) == false && double_check?(round) == false
        moves << new_move
      elsif move_in_bounds?(new_move) && enemy_piece?(new_move, round) && double_check?(round) == false
        moves << new_move
        break
      else
        break
      end
    end
    moves
  end


  def king(king_coordinates, round, black_attacks, white_attacks)
    row = king_coordinates[0] 
    col = king_coordinates[1]
    base_moves = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
    king_moves = []

    base_moves.each do |move|
      possible_move = [row + move[0], col + move[1]]
      if move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == false && king_legal_move?(possible_move, round, black_attacks, white_attacks) == true
        king_moves << possible_move
      elsif move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == true
        generate_protected_positions(move, king_coordinates, round)
      end
    end
    king_moves = king_in_check(king_coordinates, king_moves, round)
  end

  # Prevent king from making illegal move and put itself into check
  def king_legal_move?(move, round, black_attacks, white_attacks)
    if round.odd? && black_attacks.include?(move) == false
      true
    elsif round.even? && white_attacks.include?(move) == false
      true
    else
      false
    end
  end

  # Return possible king moves off of check line
  def king_in_check(coordinates, moves, round)
    if @king_black_checks.empty? == false && round.odd?
      puts "Check!"
      moves = moves - @king_black_checks.flatten(1) 
    elsif @king_white_checks.empty? == false && round.even?
      puts "Check!"
      moves = moves - @king_white_checks.flatten(1) 
    else
      moves
    end
  end

  # Return friendly possible moves when in check on attack line or capture
  def friendly_moves_in_check(coordinates, moves, round)
    if @black_checks.empty? == false && round.odd?
      moves = moves & @black_checks.flatten(1) 
    elsif @white_checks.empty? == false && round.even?
      moves = moves & @white_checks.flatten(1) 
    else
      moves
    end
  end


# See what moves a pinned piece can make
def pinned_moves(coordinates, possible_moves, round)
  if @black_pins[coordinates] != nil && round.odd?
    new_moves = possible_moves & @black_pins[coordinates]
  elsif
    @white_pins[coordinates] != nil && round.even?
    new_moves = possible_moves & @white_pins[coordinates]
  else 
    new_moves = possible_moves
  end
  new_moves
end


  # Create line for friendly pieces to block or capture checks
  # King attack line for king to move out of way or capture check piece
  # check the piece type based off of given coordinates
  def generate_check(move, coordinates, round)
    white_pieces = [' ♗ ', ' ♖ ', ' ♕ ', ' ♘ ', ' ♙ ']
    black_pieces = [' ♝ ', ' ♜ ', ' ♛ ', ' ♞ ', ' ♟ ']
    piece = @chessboard[coordinates[0]][coordinates[1]]

    if black_pieces.include?(piece)
      black_possible_check = check_attack_line(move, coordinates, 2, ' ♔ ')
      add_checks(black_possible_check, coordinates, 2, ' ♔ ', @black_checks)

      possible_black_king = king_attack_line(move, coordinates, 2, ' ♔ ')
      add_king_checks(possible_black_king, coordinates, 2, ' ♔ ', @king_black_checks)

    elsif white_pieces.include?(piece)
      white_possible_check = check_attack_line(move, coordinates, 1, ' ♚ ')
      add_checks(white_possible_check, coordinates, 1, ' ♚ ', @white_checks)

      possible_white_king = king_attack_line(move, coordinates, 1, ' ♚ ')
      add_king_checks(possible_white_king, coordinates, 1, ' ♚ ', @king_white_checks)
    end
  end

  # Adds friendly check line to an array instance variable
  def add_checks(moves, coordinates, round, king_color, checks)
    king = find_king(moves, king_color)
    enemy = pin_line_pieces(moves, round)

    if king == true && enemy == 1
      moves << coordinates
      checks << moves
    end
  end

  # Adds check line for king movement to instance variable
  def add_king_checks(moves, coordinates, round, king_color, checks)
    king = find_king(moves, king_color)

    if king == true
      checks << moves
    end
  end


  # For friendly pieces to block or capture checks
  def check_attack_line(move, coordinates, round, king)
    line_piece = [' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
    non_line = [' ♘ ', ' ♙ ', ' ♞ ', ' ♟ ']
    moves = []
    row = coordinates[0] 
    col = coordinates[1]

    if line_piece.include?(@chessboard[row][col])
      proccess_attack_line(move, row, col, round, king, moves)
    else non_line.include?(@chessboard[row][col])
      pawn_knight_checks(move, row, col, round, king, moves)
    end
    moves
  end


  def proccess_attack_line(move, row, col, round, king, moves)
    7.times do
      row = row + move[0]
      col = col + move[1]
      new_move = [row, col]
      #puts "Checking position[#{row}][#{col}]: #{@chessboard[row][col]}"
      if move_in_bounds?(new_move) && friendly_piece?(new_move, round) == false && enemy_piece?(new_move, round) == false
        moves << new_move
      elsif move_in_bounds?(new_move) && enemy_piece?(new_move, round) == true && @chessboard[row][col] == king
        moves << new_move
        break
      else
        break
      end
    end
  end

  def pawn_knight_checks(move, row, col, round, king, moves)
    row = row + move[0]
    col = col + move[1]
    new_move = [row, col]
    #puts "Checking position[#{row}][#{col}]: #{@chessboard[row][col]}"
    if move_in_bounds?(new_move) && enemy_piece?(new_move, round) == true && @chessboard[row][col] == king
    p  moves << new_move
    end
  end

  # Create enemy moves for king to move out of way or capture checking piece 
  def king_attack_line(move, coordinates, round, king)
    line_piece = [' ♗ ', ' ♖ ', ' ♕ ', ' ♝ ', ' ♜ ', ' ♛ ']
    non_line = [' ♘ ', ' ♙ ', ' ♞ ', ' ♟ ']
    moves = []
    row = coordinates[0] 
    col = coordinates[1]

    if line_piece.include?(@chessboard[row][col])
      proccess_king_attack_line(move, row, col, round, king, moves)
    else non_line.include?(@chessboard[row][col])
      pawn_knight_checks(move, row, col, round, king, moves)
    end
    
    moves
  end

  # Helper function create line for king to move out of
  def proccess_king_attack_line(move, row, col, round, king, moves)
    7.times do
      row = row + move[0]
      col = col + move[1]
      new_move = [row, col]
      #puts "Checking position[#{row}][#{col}]: #{@chessboard[row][col]}"
      if move_in_bounds?(new_move) && friendly_piece?(new_move, round) == false && enemy_piece?(new_move, round) == false
        moves << new_move
      elsif move_in_bounds?(new_move) && enemy_piece?(new_move, round) == true && @chessboard[row][col] == king
        moves << new_move
      elsif move_in_bounds?(new_move) && friendly_piece?(new_move, round)
        moves << new_move
        break
      else
        break
      end
    end
  end


  # Called in line traversal pieces to check for pins
  # check what color the coordinates are?
  def pins(move, coordinates, round)
    white_pinners = [' ♗ ', ' ♖ ', ' ♕ ']
    black_pinners = [' ♝ ', ' ♜ ', ' ♛ ']
    piece = @chessboard[coordinates[0]][coordinates[1]]


    if black_pinners.include?(piece)
      black_moves = line_of_attack(move, coordinates, 2, ' ♔ ')
      check_pins(black_moves, coordinates, 2, ' ♔ ', @black_pins)
    elsif white_pinners.include?(piece)
      white_moves = line_of_attack(move, coordinates, 1, ' ♚ ')
      check_pins(white_moves, coordinates, 1, ' ♚ ', @white_pins)
    end
  end

  # Returns line of attack for line movement pieces to calculate pins
  # stops pin line traversal once king is reached
  def line_of_attack(move, coordinates, round, king)
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
        break if @chessboard[row][col] == king
      else
        break
      end
    end
    moves
  end

  # check if line of attack has two enemy pieces including a king
  # return position of first pinned piece as key and pin line as values into hash
  def check_pins(moves, coordinates, round, king_color, pins)
    if moves.empty? == false
      algebraic_pins(moves)
    end

    king = find_king(moves, king_color)
    enemy = pin_line_pieces(moves, round)

    if king == true && enemy == 2
      pinned = find_pinned_piece(moves, round, king)
      moves << coordinates
      pins[pinned] = moves
    end
  end

  # Need two enemy pieces to meet pin criteria, check for how many enemy
  def pin_line_pieces(moves, round)
    enemy = 0

    moves.each do |index|
      if enemy_piece?(index, round)
        enemy += 1
      elsif friendly_piece?(index, round)
        break
      end
    end

    enemy
  end

  def find_pinned_piece(moves, round, king)
    piece = nil

    moves.each do |move|
      row = move[0]
      col = move[1]
      if enemy_piece?(move, round) && @chessboard[row][col] != king
        piece = move
        break
      end
    end
    piece
  end

  # checks if pin line of attack contains a king
  def find_king(moves, king_color)
    king = false

    moves.each do |index|
      row = index[0]
      col = index[1]
      #puts "Checking position[#{row}][#{col}]: #{@chessboard[row][col]}"
      if @chessboard[row][col] == king_color
        king = true
        break
      end
    end
  
    king
  end



  def generate_protected_positions(move, coordinates, round)
    white_line_piece = [' ♗ ', ' ♖ ', ' ♕ ']
    black_line_piece = [' ♝ ', ' ♜ ', ' ♛ ']
    black_non_line = [' ♞ ', ' ♟ ']
    whte_non_line = [' ♘ ', ' ♙ ']
  
    row = coordinates[0] 
    col = coordinates[1]

    if white_line_piece.include?(@chessboard[row][col])
      line_protected(move, coordinates, 1, @white_protected)
    elsif whte_non_line.include?(@chessboard[row][col])
      pawn_knight_protected(move, row, col, coordinates, 1, @white_protected)

    elsif black_line_piece.include?(@chessboard[row][col])
    line_protected(move, coordinates, 2, @black_protected)
    else black_non_line.include?(@chessboard[row][col])
      pawn_knight_protected(move, row, col, coordinates, 2, @black_protected)
    end
    
  end

  def line_protected(move, coordinates, round, protected_moves)
    row = coordinates[0] 
    col = coordinates[1]
    7.times do
      row = row + move[0]
      col = col + move[1]
      new_move = [row, col]
      if move_in_bounds?(new_move) && friendly_piece?(new_move, round) == true && enemy_piece?(new_move, round) == false
        protected_moves << new_move
        break
      end
    end
  end

  def pawn_knight_protected(move, row, col, coordinates, round, protected_moves)
    row = row + move[0]
    col = col + move[1]
    new_move = [row, col]
    #puts "Checking position[#{row}][#{col}]: #{@chessboard[row][col]}"
    if move_in_bounds?(new_move) && friendly_piece?(new_move, round) == true && enemy_piece?(new_move, round) == false
      protected_moves << new_move
    end
  end


  def castling
    #squares between king and rook are vacant
    # use a flag if king or rook has moved from their original position?
  end

  # Show notation For faster puts testing
  def algebraic_pins(moves)
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
# PIECES
# win conditions

# edge cases
  # stalemate if king has no available moves draw / possible move array empty
  # pawn promotion / promote to queen when reaching opposite side
  # castling, use flags / prompt
    # add rook to possible move list? if flag
    # select / king / select castle
    # rook next to king starting position / king on outside
    # all rows empty
  # en passant
    # pawn can capture enemy pawn if enemy skips in both positions
    # move must be made immediately after skipping

# put pieces into sub classes?
# list of possible moves
# learn how to refresh/clear console and update after every move?
  # or simulate it
# simple ai / select game mode
  # player vs player
  # player vs computer
    # randomly select piece
    # randomly select move
# serializer


# other classes
# display class?
# movement / validate moves
  # edge cases, pawn promotion, en_passant, castling, 

#Private, style guide, clean code