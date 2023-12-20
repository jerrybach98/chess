require 'json'
require_relative 'board'
require_relative 'piece'

# Basic AI generating random moves
class Computer
  attr_accessor :chessboard

  def initialize(board, piece)
    @board = board
    @chessboard = board.chessboard
    @piece = piece
  end

  def pick_random_piece(white_attacks, black_attacks)
    pieces = valid_black_piece(white_attacks, black_attacks)
    pieces.sample
  end

  def pick_random_move(selected_piece, white_attacks, black_attacks)
    available_moves = @piece.check_piece(selected_piece, 2, black_attacks, white_attacks)
    random_move = available_moves.sample
  end

  private

  # Iterate through board and choose a black piece containing valid moves
  def valid_black_piece(white_attacks, black_attacks)
    pieces = [' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ', ' ♟ ']
    ai_positions = []
    indexes = @board.board_indexes

    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      available_moves = @piece.check_piece(index, 2, black_attacks, white_attacks)
      ai_positions << index if pieces.include?(element) && available_moves.any?
    end

    ai_positions
  end
end
