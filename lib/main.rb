require 'json'

class Game
  attr_accessor :round, :selected_possible_moves, :notation_moves, :white_attacks, :black_attacks, :all_white_moves, :all_black_moves, :mode, :printed_ai_move

  def initialize(board, player, piece, special, computer)
    @board = board
    @chessboard = board.chessboard
    @player = player
    @piece = piece
    @round = 1
    @selected_possible_moves = []
    @notation_moves = []
    @white_attacks = []
    @black_attacks = []
    @all_white_moves = []
    @all_black_moves = []
    @special = special
    @mode = nil
    @computer = computer
    @printed_ai_move = nil
  end

  def set_instance(serializer)
    @serializer = serializer
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

  def select_mode
    puts "\nSelect game mode:"
    puts "[1] Player vs Player"
    puts "[2] Player vs Computer"
    loop do
      mode = gets.chomp.to_i
      return mode if mode.between?(1,2)

      puts 'Enter 1 or 2 to select mode'
    end
    
    mode
  end

  def introduction
    print "\e[2J\e[H"
    puts "Welcome to chess!"
    puts "\nHow to play:"
    puts "\nUsing algebraic notation eg. d2"
    puts "1. Enter the position of the piece you want to select"
    puts "2. Enter where you want to move the piece"
    @board.display_board
    puts "\nEnter 'save' while playing to save game"
  end

  def new_or_saved
    puts "\n[1] New Game"
    puts "[2] Load Game"

    loop do
      mode = gets.chomp

      if mode == '1'
        break
      elsif mode == '2'
        # load game function
        @serializer.load_game
        p "load successful"
        # modified display method
        # into game loop / add flag for reseting game state variables?
      else
        puts "Please enter '1' or '2'"
      end
    end
  end

  def play_game
    introduction()
    new_or_saved()
    @mode = select_mode().to_i
    print "\e[2J\e[H"
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
      #debug_announcements()
      all_possible_attacks()
      return if win_condition?
      game_mode_move()
      implement_special_moves()
      print "\e[2J\e[H"
      @board.display_board
      print_ai_move()
      @round += 1
    end
  end

  def player_turn
    if @round.odd? 
      "White"
    elsif @round.even?
      "Black"
    end
  end

  # Choose between player input or AI generated depending on selected mode
  def game_mode_move
    if @round.even? && @mode == 2
      sleep 1
      ai_move()
    else 
      prompt_move
    end
  end

  def prompt_move 
    puts "#{player_turn}: Select a piece"
    selection = prompt_valid_selection()
    print "\e[2J\e[H"
    @board.display_board
    puts "Possible Moves: #{@notation_moves.sort{|a, b| a <=> b}.join(', ')}"
    puts "#{player_turn}: Select a position"
    move = prompt_valid_move()
    @board.move_piece(selection, move)
  end

  def ai_move
    ai_selection = @computer.pick_random_piece(@white_attacks, @black_attacks)
    # puts "Black piece: #{black_ai.sort{|a, b| a <=> b}.join(', ')}"
    
    ai_move = @computer.pick_random_move(ai_selection, @white_attacks, @black_attacks)
    @board.move_piece(ai_selection, ai_move)

    print_move = [ai_move]
    @printed_ai_move = algebraic_possible_moves(print_move).join(', ')
  end

  def print_ai_move()
    if @round.even? && @mode == 2
      puts "Computer moved to: #{@printed_ai_move}"
    end
  end

  # player input gets converted to array coordinates here
  def prompt_valid_selection
    loop do 
      chess_notation = @player.get_player_input
      array_position = @board.select_piece(chess_notation)
      @selected_possible_moves = @piece.check_piece(array_position, @round, @black_attacks, @white_attacks) # check what piece is being selected and return possible moves
      @notation_moves = algebraic_possible_moves(@selected_possible_moves)
      # if possible moves.empty? when selecting, deselect the piece
      return array_position if @piece.friendly_piece?(array_position, @round) && @selected_possible_moves.any?
      puts "\nInvalid selection, enter a valid piece with algebraic notation"
      rescue NoMethodError
      puts "\nInvalid selection, enter a valid piece with algebraic notation"
    end
  end

  #def exit_game(input)
  #  if input == 'save'
  #    exit
  #  end
  #end

  # get chess notation and convert to array position
  def prompt_valid_move
    loop do
      chess_notation = @player.get_player_input
      array_move = @board.select_piece(chess_notation)
       if @selected_possible_moves.include?(array_move) && @piece.move_in_bounds?(array_move)
        #p "Round number: #{@round}"
        return array_move
       end
      puts "\nInvalid, enter a move with algebraic notation"
      rescue NoMethodError
        puts "\nInvalid, enter a move with algebraic notation"
    end
  end

  # List of possible attacks and protected pieces to prevent enemy king from moving on
  # Pawn attacks are edge cases since they attack different from traversal
  def list_white_attacks(indexes)
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
    # #concat white_protected
    @white_attacks = @white_attacks.concat(@piece.white_protected).uniq
  end


  def list_black_attacks(indexes)
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
  
    @black_attacks = @black_attacks.concat(@piece.black_protected).uniq
  end

  # Calls functions that show all possible attacks on empty spaces, enemy units, and protected pieces so that King can't move over them
  def all_possible_attacks
    indexes = @board.board_indexes
    white = algebraic_possible_moves(list_white_attacks(indexes))
    black = algebraic_possible_moves(list_black_attacks(indexes))
    #puts "White Attacks #{white}"
    #puts "Black Attacks #{black}"
  end

  # Generates a list of possible moves that can be made by every piece. Moves will be limited when King is in check forcing to act on check. If there is no moves available in check, it will be a checkmate and end
  def checkmate?(white, black)
    if white.empty? && @piece.king_black_checks.empty? == false || black.empty? && @piece.king_white_checks.empty? == false
      true
    else
      false
    end
  end

  def stalemate?(white, black)
    if white.empty? || black.empty?
      true
    else
      false
    end
  end

  def win_condition?
    indexes = @board.board_indexes
    white = algebraic_possible_moves(generate_white_moves(indexes))
    black = algebraic_possible_moves(generate_black_moves(indexes))
    #puts "White moves for check: #{white}"
    #puts "Black moves for check: #{black}"

    if checkmate?(white, black)
      puts "Checkmate!"
      true
    elsif stalemate?(white, black)
      puts "stalemate!"
      true
    elsif @piece.king_black_checks.empty? == false && round.odd? || @piece.king_white_checks.empty? == false && round.even?
      puts "Check!"
      false
    else
      false
    end
  end

  # See what moves are available especially in check, if moves are unavailble then it is a checkmate
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
    black = [' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ', ' ♟ ']

    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      if black.include?(element)
        @all_black_moves.concat(@piece.check_piece(index, 2, @all_black_moves, @white_attacks))
      end
    end

    @all_black_moves
  end

  def implement_special_moves
    @special.pawn_promotion
    @special.update_board_castle
    @special.flag_castle_positions
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
    @piece.white_protected = []
    @piece.black_protected = []
  end
end

class Board
  attr_accessor :chessboard, :display

  def initialize
    @chessboard = [
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♔ ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♙ ', '   ', ' ♖ ', '   ', '   ', '   ', '   ', ' ♟ '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', ' ♚ ', '   ', '   ', '   ', '   ', '   ', '   ']
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

  def initialize(board, special)
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
    @special = special
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
      elsif move_in_bounds?(possible_attack) && friendly_piece?(possible_attack, round) == true
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
    castle_moves = king_moves.concat(@special.castling(king_coordinates, round, @king_white_checks, @king_black_checks, white_attacks, black_attacks))
    king_moves = king_in_check(king_coordinates, castle_moves, round)
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

  # Return possible king moves in check by removing any moves from the check line
  def king_in_check(coordinates, moves, round)
    if @king_black_checks.empty? == false && round.odd?
      # puts "Check!"
      moves = moves - @king_black_checks.flatten(1) 
    elsif @king_white_checks.empty? == false && round.even?
      # puts "Check!"
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

  # when Pawn or knight puts king in check
  def pawn_knight_checks(move, row, col, round, king, moves)
    row = row + move[0]
    col = col + move[1]
    new_move = [row, col]
    #puts "Checking position[#{row}][#{col}]: #{@chessboard[row][col]}"
    if move_in_bounds?(new_move) && enemy_piece?(new_move, round) == true && @chessboard[row][col] == king
      moves << new_move
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


  # Generates list of pieces that have another piece protecting it 
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
  end

  def set_instance(serializer)
    @serializer = serializer
  end

  # might need to create instance of serializer method to save game and call function

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

end

class Special_moves
  attr_accessor :a1_rook, :h1_rook, :white_king, :a8_rook, :h8_rook, :black_king

  def initialize(board)
    @board = board
    @chessboard = board.chessboard

    @a1_rook = true
    @h1_rook = true
    @white_king = true
    @a8_rook = true
    @h8_rook = true
    @black_king = true
  end

  def pawn_promotion
    indexes = @board.board_indexes()

    indexes.each do |index|
      row = index[0]
      col = index[1]
      #puts "Checking position[#{row}][#{col}]: #{@chessboard[row][col]}"

      if row == 7 && @chessboard[row][col] == ' ♙ '
        @chessboard[row][col] = ' ♕ '
      elsif row == 0 && @chessboard[row][col] == ' ♟ ' 
        @chessboard[row][col] = ' ♛ '
      end
    end
  end

  def flag_castle_positions
    @a1_rook = false if @chessboard[0][0] != ' ♖ '
    @h1_rook = false if @chessboard[0][7] != ' ♖ '
    @white_king = false if @chessboard[0][4] != ' ♔ '
    @a8_rook = false if @chessboard[7][0] != ' ♜ '
    @h8_rook = false if @chessboard[7][7] != ' ♜ '
    @black_king = false if @chessboard[7][4] != ' ♚ '

    #p "a1_rook #{@a1_rook}"
    #p "h1_rook #{@h1_rook}"
    #p "white_king #{@white_king}"
    #p "a8_rook #{@a8_rook}"
    #p "h8_rook #{@h8_rook}"
    #p "black_king #{@black_king}"

  end

  # Check if each castle side is available and add King's castle position to base moves
  def castling(king_coordinates, round, white_check_line, black_check_line, white_attacks, black_attacks)
    row = king_coordinates[0] 
    col = king_coordinates[1]
    w_kingside_pos = [0, 6]
    w_queenside_pos = [0, 2]
    b_kingside_pos = [7, 6]
    b_queenside_pos = [7, 2]
    castle_moves = []

    if white_kingside_castle?(row, col, black_check_line, black_attacks)
      castle_moves << w_kingside_pos
    elsif black_kingside_castle?(row, col, white_check_line, white_attacks)
      castle_moves << b_kingside_pos
    end
    
    if white_queenside_castle?(row, col, black_check_line, black_attacks)
      castle_moves << w_queenside_pos
    elsif black_queenside_castle?(row, col, white_check_line, white_attacks)
      castle_moves << b_queenside_pos
    end

    castle_moves
  end

  # Castle Availability: Check King Color, can't escape check, no pieces between, no attacks between, and if pieces have already moved
  # White works now check black
  def white_kingside_castle?(row, col, black_check_line, black_attacks)
    if @chessboard[row][col] == ' ♔ ' && black_check_line.empty? && @chessboard[0][5] == '   ' && @chessboard[0][6] == '   ' && black_attacks.include?([0, 5]) == false && black_attacks.include?([0, 6]) == false && @h1_rook == true && @white_king == true
      true
    end
  end

  def white_queenside_castle?(row, col, black_check_line, black_attacks)
    if @chessboard[row][col] == ' ♔ ' && black_check_line.empty? && @chessboard[0][1] == '   ' && @chessboard[0][2] == '   ' && @chessboard[0][3] == '   ' && black_attacks.include?([0, 2]) == false && black_attacks.include?([0, 3]) == false && @a1_rook == true && @white_king == true
      true
    end
  end

  def black_kingside_castle?(row, col, white_check_line, white_attacks)
    if @chessboard[row][col] == ' ♚ ' && white_check_line.empty? && @chessboard[7][5] == '   ' && @chessboard[7][6] == '   ' && white_attacks.include?([7, 5]) == false && white_attacks.include?([7, 6]) == false && @a8_rook == true && @black_king == true
      true
    end
  end

  def black_queenside_castle?(row, col, white_check_line, white_attacks)
    if @chessboard[row][col] == ' ♚ ' && white_check_line.empty? && @chessboard[7][1] == '   ' && @chessboard[7][2] == '   ' && @chessboard[7][3] == '   ' && white_attacks.include?([7, 2]) == false && white_attacks.include?([7, 3]) == false && @h8_rook == true && @black_king == true
      true
    end
  end


    # check board positions like in pawn promotion
    # if king is in castle location
    # and if the specific cornerside flags are still true
    # move the castle next to king's original position
    # figure out where to put it as moving the king might trigger the flag_castle_positions method
  def update_board_castle
    if @chessboard[0][6] == ' ♔ ' && @h1_rook == true && @white_king == true
      @chessboard[0][5] = ' ♖ '
      @chessboard[0][7] = '   '
    elsif @chessboard[0][2] == ' ♔ ' && @a1_rook == true && @white_king == true
      @chessboard[0][3] = ' ♖ '
      @chessboard[0][0] = '   '
    elsif @chessboard[7][6] == ' ♚ ' && @a8_rook == true && @black_king == true
      @chessboard[7][5] = ' ♜ '
      @chessboard[7][7] = '   '
    elsif @chessboard[7][2] == ' ♚ ' && @h8_rook == true && @black_king == true
      @chessboard[7][3] = ' ♜ '
      @chessboard[7][0] = '   '
    end
  end
end


class Serializer
  def initialize(board, player, piece, special, computer, game)
    @board = board
    @player = player
    @piece = piece
    @special = special
    @computer = computer
    @game = game
  end


  # Makes path to saved games in parent directory from the current directory to store game state
  def save_game
    puts 'Enter a filename for your saved game:'
    file_name = gets.chomp.strip

    save_folder_path = File.expand_path('../saved_games', __dir__)
    Dir.mkdir(save_folder_path) unless Dir.exist?(save_folder_path)
    File.open(File.join(save_folder_path, "#{file_name}.json"), 'w') do |file|
      file.puts(JSON.dump({
                            chessboard: @board.chessboard,
                            display: @board.display,

                            white_pins: @piece.white_pins,
                            black_pins: @piece.black_pins,
                            white_checks: @piece.white_checks,
                            black_checks: @piece.black_checks,
                            king_white_checks: @piece.king_white_checks,
                            king_black_checks: @piece.king_black_checks,
                            black_protected: @piece.black_protected,
                            white_protected: @piece.white_protected,
                            
                            a1_rook: @special.a1_rook,
                            h1_rook: @special.h1_rook,
                            white_king: @special.white_king,
                            a8_rook: @special.a8_rook,
                            h8_rook: @special.h8_rook,
                            black_king: @special.black_king,
                            
                            round: @game.round,
                            selected_possible_moves: @game.selected_possible_moves,
                            notation_moves: @game.notation_moves,
                            white_attacks: @game.white_attacks,
                            black_attacks: @game.black_attacks,
                            all_white_moves: @game.all_white_moves,
                            all_black_moves: @game.all_black_moves,
                            mode: @game.mode,
                            printed_ai_move: @game.printed_ai_move,
                          }))
    end
    puts 'Game saved successfully!'
    exit
  end

  def load_game
    puts "\nSaved files:"
    save_folder_path = File.join(File.expand_path('..', __dir__), 'saved_games')
    Dir.children(save_folder_path).each { |file| puts file.slice(0..-6) }
    puts ' '
    puts 'Enter the filename you would like to load:'

    loop do
      file_name = gets.chomp.strip
      file_path = File.join(save_folder_path, "#{file_name}.json")

      if File.exist?(file_path)
        json = JSON.load_file(file_path)
        @board.chessboard = json['chessboard']
        @board.display = json['display']

        @piece.white_pins = json['white_pins']
        @piece.black_pins = json['black_pins']
        @piece.white_checks = json['white_checks']
        @piece.black_checks = json['black_checks']
        @piece.king_white_checks = json['king_white_checks']
        @piece.king_black_checks = json['king_black_checks']
        @piece.black_protected = json['black_protected']
        @piece.white_protected = json['white_protected']

        @special.a1_rook = json['a1_rook']
        @special.h1_rook = json['h1_rook']
        @special.white_king = json['white_king']
        @special.a8_rook = json['a8_rook']
        @special.h8_rook = json['h8_rook']
        @special.black_king = json['black_king']

        @game.round = json['round']
        @game.selected_possible_moves = json['selected_possible_moves']
        @game.notation_moves = json['notation_moves']
        @game.white_attacks = json['white_attacks']
        @game.black_attacks = json['black_attacks']
        @game.all_white_moves = json['all_white_moves']
        @game.all_black_moves = json['all_black_moves']
        @game.mode = json['mode']
        @game.printed_ai_move = json['printed_ai_move']
        break
      else
        puts 'File not found, please enter the name of a saved file:'
      end
    end
  end

end

class Computer
  def initialize(board, piece)
    @board = board
    @chessboard = board.chessboard
    @piece = piece
  end

  def pick_random_piece(white_attacks, black_attacks)
    pieces = valid_black_piece(white_attacks, black_attacks)
    return pieces.sample
  end

  # Iterate through board and choose a black piece with valid moves
  def valid_black_piece(white_attacks, black_attacks)
    pieces = [' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ', ' ♟ ']
    ai_positions = []
    indexes = @board.board_indexes()

    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      available_moves = @piece.check_piece(index, 2, black_attacks, white_attacks)
      if pieces.include?(element) && available_moves.any?
        ai_positions << index
      end
    end

    ai_positions
  end

  def pick_random_move(selected_piece, white_attacks, black_attacks)
    available_moves = @piece.check_piece(selected_piece, 2, black_attacks, white_attacks)
    random_move = available_moves.sample
  end


end

board = Board.new
special = Special_moves.new(board)
piece = Piece.new(board, special)
player = Player.new(board, piece)
computer = Computer.new(board, piece)
game = Game.new(board, player, piece, special, computer)
serializer = Serializer.new(board, player, piece, special, computer, game)
player.set_instance(serializer)
game.set_instance(serializer)
game.play_game



# serializer / save (done before on hangman)
  # save instance variables

# put pieces into sub classes? rook < piece or keep
# put tests in folder
#Private, style guide, clean code