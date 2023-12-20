require 'json'
require_relative 'board'
require_relative 'special'
require_relative 'piece'
require_relative 'player'
require_relative 'computer'

# Handles game state and win conditions
class Game
  attr_accessor :round, :selected_possible_moves, :notation_moves, :white_attacks, :black_attacks, :all_white_moves, :all_black_moves, :mode, :printed_ai_move, :chessboard

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
    @loaded_game = false
  end

  def set_instance(serializer)
    @serializer = serializer
  end

  def play_game
    introduction
    new_or_saved
    @mode = select_mode.to_i if @loaded_game == false
    @board.reset_board_display
    game_loop
  end

  private

  # Display array positions in chess notation
  def algebraic_possible_moves(moves)
    return if moves.nil?

    moves.map do |move|
      array = move.reverse
      row = (array[0] + 97).chr
      col = (array[1] + 1).to_s
      notation = [row, col].join('')
    end
  end

  def select_mode
    puts "\nSelect game mode:"
    puts '[1] Player vs Player'
    puts '[2] Player vs Computer'
    loop do
      mode = gets.chomp.to_i
      return mode if mode.between?(1, 2)

      puts 'Enter 1 or 2 to select mode'
    end

    mode
  end

  def introduction
    print "\e[2J\e[H"
    puts 'Welcome to chess!'
    puts "\nHow to play:"
    puts "\nUsing algebraic notation eg. d2"
    puts '1. Enter the position of the piece you want to select'
    puts '2. Enter where you want to move the piece'
    @board.display_board
    puts "\nEnter 'save' while playing to save game"
  end

  # New game will continue to the game loop
  def new_or_saved
    puts "\n[1] New Game"
    puts '[2] Load Game'

    loop do
      mode = gets.chomp

      if mode == '1'
        break
      elsif mode == '2'
        @serializer.load_game
        @loaded_game = true
        break
      else
        puts "Please enter '1' or '2'"
      end
    end
  end

  # If the game is loaded, it will skip mode selection
  def loaded_game_flag
    return unless @loaded_game == true

    @loaded_game = false
    puts 'Game loaded successfully:'
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
      loaded_game_flag
      reset_game_state
      all_possible_attacks
      return if win_condition?

      # debug_announcements()
      ai_or_player_move
      implement_special_moves
      @board.reset_board_display
      print_ai_move
      @round += 1
    end
  end

  def player_turn
    if @round.odd?
      'White'
    elsif @round.even?
      'Black'
    end
  end

  # Choose between player input or AI generated move depending on mode for black. Delay AI move to simulate a player.
  def ai_or_player_move
    if @round.even? && @mode == 2
      sleep 1
      ai_move
    else
      prompt_move
    end
  end

  # Calls logic to get both a player's selection then move to update board
  def prompt_move
    puts "#{player_turn}: Select a piece"
    selection = prompt_valid_selection
    @board.reset_board_display
    puts "Possible Moves: #{@notation_moves.sort { |a, b| a <=> b }.join(', ')}"
    puts "#{player_turn}: Select a position"
    move = prompt_valid_move
    @board.move_piece(selection, move)
  end

  # Generates AI move
  def ai_move
    ai_selection = @computer.pick_random_piece(@white_attacks, @black_attacks)
    ai_move = @computer.pick_random_move(ai_selection, @white_attacks, @black_attacks)
    @board.move_piece(ai_selection, ai_move)

    print_move = [ai_move]
    @printed_ai_move = algebraic_possible_moves(print_move).join(', ')
  end

  def print_ai_move
    return unless @round.even? && @mode == 2

    puts "Computer moved to: #{@printed_ai_move}"
  end

  # Select piece then converts to array coordinates and checks validity
  def prompt_valid_selection
    loop do
      chess_notation = @player.get_player_input
      array_position = @board.select_piece(chess_notation)
      @selected_possible_moves = @piece.check_piece(array_position, @round, @black_attacks, @white_attacks)
      @notation_moves = algebraic_possible_moves(@selected_possible_moves)
      return array_position if @piece.friendly_piece?(array_position, @round) && @selected_possible_moves.any?

      puts "\nInvalid selection, enter a valid piece with algebraic notation"
    rescue NoMethodError
      puts "\nInvalid selection, enter a valid piece with algebraic notation"
    end
  end

  # Get player move and check for validity
  def prompt_valid_move
    loop do
      chess_notation = @player.get_player_input
      array_move = @board.select_piece(chess_notation)
      return array_move if @selected_possible_moves.include?(array_move) && @piece.move_in_bounds?(array_move)

      puts "\nInvalid, enter a move with algebraic notation"
    rescue NoMethodError
      puts "\nInvalid, enter a move with algebraic notation"
    end
  end

  # List of possible attacks and protected pieces to prevent enemy king from moving on. Pawn attacks are edge cases since they attack different from their traversal
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

  # Call function that collects all possible capture positions on empty spaces, units, and protected pieces so that King can't move over them
  def all_possible_attacks
    indexes = @board.board_indexes
    white = algebraic_possible_moves(list_white_attacks(indexes))
    black = algebraic_possible_moves(list_black_attacks(indexes))
  end

  # Check if moves are available and if king is in Check, resulting in a checkmate
  def checkmate?(white, black)
    if white.empty? && @piece.king_black_checks.empty? == false || black.empty? && @piece.king_white_checks.empty? == false
      true
    else
      false
    end
  end

  # If no moves are available on a side, the game is a stalemate
  def stalemate?(white, black)
    if white.empty? || black.empty?
      true
    else
      false
    end
  end

  # Flag for win conditions or if a player is in Check
  def win_condition?
    indexes = @board.board_indexes
    white = algebraic_possible_moves(generate_white_moves(indexes))
    black = algebraic_possible_moves(generate_black_moves(indexes))

    if checkmate?(white, black)
      puts 'Checkmate!'
      true
    elsif stalemate?(white, black)
      puts 'stalemate!'
      true
    elsif @piece.king_black_checks.empty? == false && round.odd? || @piece.king_white_checks.empty? == false && round.even?
      puts 'Check!'
      false
    else
      false
    end
  end

  # Generate available moves used for win condition logic
  def generate_white_moves(indexes)
    white = [' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ', ' ♙ ']

    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      @all_white_moves.concat(@piece.check_piece(index, 1, @black_attacks, @all_white_moves)) if white.include?(element)
    end
    @all_white_moves
  end

  def generate_black_moves(indexes)
    black = [' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ', ' ♟ ']

    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      @all_black_moves.concat(@piece.check_piece(index, 2, @all_black_moves, @white_attacks)) if black.include?(element)
    end

    @all_black_moves
  end

  # Call function to check for special moves
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