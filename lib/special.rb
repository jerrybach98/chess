require 'json'
require_relative 'board'

# Special move logic and board update
class Special
  attr_accessor :a1_rook, :h1_rook, :white_king, :a8_rook, :h8_rook, :black_king, :chessboard

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

  # Promote pawn to queen when reaching other side
  def pawn_promotion
    indexes = @board.board_indexes
    indexes.each do |index|
      row = index[0]
      col = index[1]
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
  end

  # Check if each castle side is available and add King's castle coordinates to its' base moves
  def castling(king_coordinates, _round, white_check_line, black_check_line, white_attacks, black_attacks)
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

  # Update board if King moves in castle position and flags are true
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

  private

  # Castle Criteria: Check king color, can't escape check, no pieces between, no attacks between, and if pieces have already moved
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
end