require 'json'
require_relative 'board'
require_relative 'special'

# Uses base moves to generate traversal, pins, checks, etc
class Piece
  attr_accessor :black_pins, :white_pins, :black_checks, :white_checks, :king_white_checks, :king_black_checks, :black_protected, :white_protected, :chessboard

  def initialize(board, special)
    @board = board
    @chessboard = board.chessboard
    @white_pins = {}
    @black_pins = {}
    @white_checks = []
    @black_checks = []
    @king_white_checks = []
    @king_black_checks = []
    @black_protected = []
    @white_protected = []
    @special = special
  end

  # Given array coordinates identify if a piece is friendly depending on the round number
  def friendly_piece?(piece_coordinates, round)
    white = [' ♙ ', ' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ']
    black = [' ♟ ', ' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
    row = piece_coordinates[0]
    col = piece_coordinates[1]
    element = @chessboard[row][col]
    if round.odd? && white.include?(element)
      true
    elsif round.even? && black.include?(element)
      true
    else
      false
    end
  end

  # Call function to check possible moves given coordinates of a piece. Each individual piece can generate a check or must move according to check/pin logic
  def check_piece(piece_coordinates, round, black_attacks, white_attacks)
    row = piece_coordinates[0]
    col = piece_coordinates[1]
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

  def move_in_bounds?(possible_moves)
    row = possible_moves[0]
    col = possible_moves[1]
    if row.between?(0, 7) && col.between?(0, 7)
      true
    else
      false
    end
  end

  # Creates list of possible pawn capture movement if enemy is in range
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

  private

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

  # Edge case if King is being checked by 2 pieces
  def double_check?(round)
    if round.odd? && @black_checks.uniq.count == 2
      true
    elsif round.even? && @white_checks.uniq.count == 2
      true
    else
      false
    end
  end

  # Add capture movement separately as they require different conditions from base traversal
  def pawn(pawn_coordinates, round)
    row = pawn_coordinates[0]
    col = pawn_coordinates[1]
    pawn_moves = []
    base_moves = pawn_first_move(pawn_coordinates)

    attacks = pawn_attacks(pawn_coordinates, round)
    pawn_moves.concat(pawn_attack_range(attacks, round))

    base_moves.map do |move|
      possible_move = [row + move[0], col + move[1]]
      next unless move_in_bounds?(possible_move) && friendly_piece?(possible_move, round) == false && enemy_piece?(possible_move, round) == false && double_check?(round) == false

      pawn_moves << possible_move
      pawn_moves = pinned_moves(pawn_coordinates, pawn_moves, round)
      pawn_moves = friendly_moves_in_check(pawn_coordinates, pawn_moves, round)
    end

    pawn_moves
  end

  # check if enemy units are in pawn capture coordinates
  def pawn_attack_range(attacks, round)
    diagonal_attacks = []

    attacks.each do |attack|
      diagonal_attacks << attack if enemy_piece?(attack, round) == true
    end
    diagonal_attacks
  end

  # Return vertical traversal moves depending on pawn position. Pawn can move two squares on first move with nothing blocking it's path
  def pawn_first_move(pawn_coordinates)
    row = pawn_coordinates[0]
    col = pawn_coordinates[1]
    pawn_moves = []

    if row == 1 && @chessboard[row][col] == ' ♙ ' && @chessboard[row + 1][col] == '   '
      pawn_moves = [[1, 0], [2, 0]]
    elsif row != 1 && @chessboard[row][col] == ' ♙ '
      pawn_moves = [[1, 0]]
    elsif row == 6 && @chessboard[row][col] == ' ♟ ' && @chessboard[row - 1][col] == '   '
      pawn_moves = [[-1, 0], [-2, 0]]
    elsif row != 6 && @chessboard[row][col] == ' ♟ '
      pawn_moves = [[-1, 0]]
    end
    pawn_moves
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

  # Increment position by base moves of line traversal pieces. Moves on empty spaces until end of board, before a friendly unit is reached, or until first enemy unit in path.
  def line_traversal(move, coordinates, round)
    moves = []
    row = coordinates[0]
    col = coordinates[1]
    7.times do
      row += move[0]
      col += move[1]
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

  # Prevent king from putting itself into check
  def king_legal_move?(move, round, black_attacks, white_attacks)
    if round.odd? && black_attacks.include?(move) == false
      true
    elsif round.even? && white_attacks.include?(move) == false
      true
    else
      false
    end
  end

  # Return possible king moves in check by removing any matching moves from the check line
  def king_in_check(_coordinates, moves, round)
    if @king_black_checks.empty? == false && round.odd?
      moves -= @king_black_checks.flatten(1)
    elsif @king_white_checks.empty? == false && round.even?
      moves -= @king_white_checks.flatten(1)
    else
      moves
    end
  end

  # Friendly moves must block a check by moving on the check line or by capturing the enemy piece
  def friendly_moves_in_check(_coordinates, moves, round)
    if @black_checks.empty? == false && round.odd?
      moves &= @black_checks.flatten(1)
    elsif @white_checks.empty? == false && round.even?
      moves &= @white_checks.flatten(1)
    else
      moves
    end
  end

  # See what moves a pinned piece can make
  def pinned_moves(coordinates, possible_moves, round)
    if !@black_pins[coordinates].nil? && round.odd?
      possible_moves & @black_pins[coordinates]
    elsif !@white_pins[coordinates].nil? && round.even?
      possible_moves & @white_pins[coordinates]
    else
      possible_moves
    end
  end

  # Call function generates array coordinates in line for friendly piece to block/capture and another line for King to move off/capture
  def generate_check(move, coordinates, _round)
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

  # Adds check line to an instance variable
  def add_checks(moves, coordinates, round, king_color, checks)
    king = find_king(moves, king_color)
    enemy = pin_line_pieces(moves, round)

    return unless king == true && enemy == 1

    moves << coordinates
    checks << moves
  end

  # For king movement
  def add_king_checks(moves, _coordinates, _round, king_color, checks)
    king = find_king(moves, king_color)

    return unless king == true

    checks << moves
  end

  # For friendly pieces to block or capture checks
  def check_attack_line(move, coordinates, round, king)
    line_piece = [' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
    non_line = [' ♘ ', ' ♙ ', ' ♞ ', ' ♟ ']
    moves = []
    row = coordinates[0]
    col = coordinates[1]

    if line_piece.include?(@chessboard[row][col])
      process_attack_line(move, row, col, round, king, moves)
    else
      non_line.include?(@chessboard[row][col])
      pawn_knight_checks(move, row, col, round, king, moves)
    end
    moves
  end

  # Calculate check line for line traversal
  def process_attack_line(move, row, col, round, king, moves)
    7.times do
      row += move[0]
      col += move[1]
      new_move = [row, col]
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
    row += move[0]
    col += move[1]
    new_move = [row, col]
    return unless move_in_bounds?(new_move) && enemy_piece?(new_move, round) == true && @chessboard[row][col] == king

    moves << new_move
  end

  # Call function generating enemy moves for king to move away or capture checking piece
  def king_attack_line(move, coordinates, round, king)
    line_piece = [' ♗ ', ' ♖ ', ' ♕ ', ' ♝ ', ' ♜ ', ' ♛ ']
    non_line = [' ♘ ', ' ♙ ', ' ♞ ', ' ♟ ']
    moves = []
    row = coordinates[0]
    col = coordinates[1]

    if line_piece.include?(@chessboard[row][col])
      process_king_attack_line(move, row, col, round, king, moves)
    else
      non_line.include?(@chessboard[row][col])
      pawn_knight_checks(move, row, col, round, king, moves)
    end

    moves
  end

  # Helper function creating line for king to move out of
  def process_king_attack_line(move, row, col, round, king, moves)
    7.times do
      row += move[0]
      col += move[1]
      new_move = [row, col]
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

  # Called in line traversal pieces to generate pin information
  def pins(move, coordinates, _round)
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

  # Returns line of attack for line movement pieces to calculate pins. Stops pin line traversal once king is reached
  def line_of_attack(move, coordinates, round, king)
    moves = []
    row = coordinates[0]
    col = coordinates[1]
    7.times do
      row += move[0]
      col += move[1]
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

  # Check if a line of attack has two enemy pieces including a king. Return position of first pinned piece as key and pin line as values into hash
  def check_pins(moves, coordinates, round, king_color, pins)
    king = find_king(moves, king_color)
    enemy = pin_line_pieces(moves, round)

    return unless king == true && enemy == 2

    pinned = find_pinned_piece(moves, round, king)
    moves << coordinates
    pins[pinned] = moves
  end

  # Need two enemy pieces to meet pin criteria, check for how many enemies
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

  # On a line traversal
  def find_king(moves, king_color)
    king = false

    moves.each do |index|
      row = index[0]
      col = index[1]
      if @chessboard[row][col] == king_color
        king = true
        break
      end
    end

    king
  end

  # Call function generating list of coordinates that have another piece protecting it. Line traversal pieces require separate logic.
  def generate_protected_positions(move, coordinates, _round)
    white_line_piece = [' ♗ ', ' ♖ ', ' ♕ ']
    black_line_piece = [' ♝ ', ' ♜ ', ' ♛ ']
    black_non_line = [' ♞ ', ' ♟ ', ' ♚ ']
    whte_non_line = [' ♘ ', ' ♙ ', ' ♔ ']

    row = coordinates[0]
    col = coordinates[1]

    if white_line_piece.include?(@chessboard[row][col])
      line_protected(move, coordinates, 1, @white_protected)
    elsif whte_non_line.include?(@chessboard[row][col])
      non_line_protected(move, row, col, coordinates, 1, @white_protected)

    elsif black_line_piece.include?(@chessboard[row][col])
      line_protected(move, coordinates, 2, @black_protected)
    else
      black_non_line.include?(@chessboard[row][col])
      non_line_protected(move, row, col, coordinates, 2, @black_protected)
    end
  end

  def line_protected(move, coordinates, round, protected_moves)
    row = coordinates[0]
    col = coordinates[1]
    7.times do
      row += move[0]
      col += move[1]
      new_move = [row, col]
      if move_in_bounds?(new_move) && friendly_piece?(new_move, round) == true && enemy_piece?(new_move, round) == false
        protected_moves << new_move
        break
      end
    end
  end

  def non_line_protected(move, row, col, _coordinates, round, protected_moves)
    row += move[0]
    col += move[1]
    new_move = [row, col]
    if move_in_bounds?(new_move) && friendly_piece?(new_move, round) == true && enemy_piece?(new_move, round) == false
      protected_moves << new_move
    end
  end

  # Array coordinates conversion for faster debugging
  def algebraic_moves(moves)
    return if moves.nil?

    moves.map do |move|
      array = move.reverse
      row = (array[0] + 97).chr
      col = (array[1] + 1).to_s
      notation = [row, col].join('')
    end
  end
end