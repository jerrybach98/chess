require './lib/main'

describe Board do
  describe 'select_piece' do
    subject(:board) { described_class.new }

    context 'when given chess notation' do
      it 'converts to a nested array value' do
        position = 'c2'
        expect(board.select_piece(position)).to eq([1,2])
      end
    end
  end
end

describe Piece do
  describe 'friendly_piece?' do
    subject(:piece) { described_class.new(board) }
    let(:board) { instance_double(Board) }
    let(:chessboard) do
      [
        [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
        [' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
        [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
      ]
    end

    context 'when given friendly white piece coordinate and round is odd' do
      before do
        allow(board).to receive(:chessboard).and_return(chessboard)
      end

      it 'returns true' do
        piece_coordinates = [1, 0]
        round = 1
        expect(piece.friendly_piece?(piece_coordinates, round)).to eq(true)
      end
    end

    context 'when given friendly black piece coordinate and round is even' do
      before do
        allow(board).to receive(:chessboard).and_return(chessboard)
      end

      it 'returns true' do
        piece_coordinates = [7, 5]
        round = 6
        expect(piece.friendly_piece?(piece_coordinates, round)).to eq(true)
      end
    end
  end

  describe 'enemy_piece?' do
    subject(:enemy) { described_class.new(board) }
    let(:board) { instance_double(Board) }
    let(:chessboard) do
      [
        [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
        [' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
        [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
      ]
    end

    context 'when given enemy black piece coordinate and round is odd' do
      before do
        allow(board).to receive(:chessboard).and_return(chessboard)
      end

      it 'returns true' do
        piece_coordinates = [7, 0]
        round = 1
        expect(enemy.enemy_piece?(piece_coordinates, round)).to eq(true)
      end
    end
  end

  describe 'bishop' do
    subject(:bishop) { described_class.new(board) }
    let(:board) { instance_double(Board) }
    let(:chessboard) do
      [
      [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
      [' ♙ ', ' ♗ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
      [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
    ]
  end
    

    context 'when bishop is on array position 1, 1' do
      before do
        allow(board).to receive(:chessboard).and_return(chessboard)
      end

      it 'returns array of correct possible values' do
        bishop_coordinates = [1, 1]
        round = 1
        expect(bishop.bishop(bishop_coordinates, round)).to eq([[2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [2, 0]])
      end
    end
  end

  describe 'knight' do
    subject(:knight) { described_class.new(board) }
    let(:board) { instance_double(Board) }
    let(:chessboard) do
      [
        [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
        [' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
        [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
      ]
    end
    

    context 'when knight is on array position 0, 1' do
      before do
        allow(board).to receive(:chessboard).and_return(chessboard)
      end

      it 'returns array of correct possible values not out of bounds or on friendly' do
        knight_coordinates = [0, 1]
        round = 1
        expect(knight.knight(knight_coordinates, round)).to eq([[2, 2], [2, 0]])
      end
    end
  end

  describe 'rook' do
    subject(:rook) { described_class.new(board) }
    let(:board) { instance_double(Board) }
    let(:chessboard) do
      [
        [' ♖ ', '   ', '   ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
        [' ♟︎ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
        [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
      ]
    end
    

    context 'when rook is on array position 0, 0' do
      before do
        allow(board).to receive(:chessboard).and_return(chessboard)
      end

      it 'returns array of correct possible values' do
        rook_coordinates = [0, 0]
        round = 1
        expect(rook.rook(rook_coordinates, round)).to eq([[1, 0], [0, 1], [0, 2]])
      end
    end
  end

  describe 'king' do
    subject(:king) { described_class.new(board) }
    let(:board) { instance_double(Board) }
    let(:chessboard) do
      [
        [' ♖ ', ' ♘ ', ' ♗ ', '   ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
        [' ♙ ', ' ♙ ', ' ♙ ', '   ', '   ', '   ', ' ♙ ', ' ♙ '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
        [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
        [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
      ]
    end
    

    context 'when king is on array position 0, 4' do
      before do
        allow(board).to receive(:chessboard).and_return(chessboard)
      end

      it 'returns array of correct possible values' do
        king_coordinates = [0, 4]
        round = 1
        black_moves = []
        white_moves = []
        expect(king.king(king_coordinates, round, black_moves, white_moves)).to eq([[1, 4], [1, 5], [0, 3], [1, 3]])
      end
    end
  end

end

describe Player do
  describe '#select_position' do
    context 'when player provides a correct board position' do
      subject(:player) { described_class.new(board, piece) }
      let(:board) { instance_double(Board) }
      let(:piece) { instance_double(Piece) }

      before do
       # allow(players).to receive(:puts)
        allow(player).to receive(:gets).and_return('a2')
      end

      it 'returns the correct position' do
        expect(player.select_position).to eq('a2')
      end
    end

    context 'when player provides an incorrect then correct board position' do
      subject(:player) { described_class.new(board, piece) }
      let(:board) { instance_double(Board) }
      let(:piece) { instance_double(Piece) }

      before do
        allow(player).to receive(:gets).and_return('a9', 'a2')
      end

      it 'displays error once then complete loop' do
        expect(player).to receive(:puts).with('Enter a position with algebraic notation').once
        player.select_position
      end
    end
  end


  describe '#valid_input?' do
    subject(:input) { described_class.new(board, piece) }
    let(:board) { instance_double(Board) }
    let(:piece) { instance_double(Piece) }

    context 'when player inputs valid input' do
      it 'returns true' do
        expect(input.valid_input?('b5')).to eq(true)
      end
    end

    context 'when player inputs an invalid input' do
      it 'returns false' do
        expect(input.valid_input?('1b')).to eq(false)
      end
    end
  end
end

    #iterate through board for line pieces/pins in game loop and call each line mover to check piece, 
    # check_piece method will call individual 
      # pass it to line traversal pieces(bishop, rook, queen)

    # make a new method similar to line traversal

    #if it's a line piece return its location and call line_of_attack on each base move
      # return line traversal of all moves / calculate line of attack

    # each indvidual line will have a function call to check for pins (matching both king and 1 enemy piece)
      # make a new method similar to line traversal, return every move in a line until king is located and return true
      # Check if there is only one enemy piece on that line, if so return true
      # two true's result in a pin

    # return that line to an instance variable?
    # compare selected piece moves to the line with instance variable

    # find pinned piece, if it falls on instance variable pin line
      # if pin return location of the pinned piece
      # if true the pinned piece can only return every move on that line
      # cross reference to piece positions for move generation, remove moves not on line

    # check for pins after every loop

    # handling double pin








  #check for check after each move
  # force king to move if in check or block/capture
    # if king shows up on enemy move array
    # check for legal moves
    # the next legal move must undo check
  # checkmate if king can't move/block/capture
    # try all legal moves, if there is no legal move, checkmate
  
    @chessboard = [
      [' ♖ ', ' ♘ ', ' ♗ ', ' ♕ ', ' ♔ ', ' ♗ ', ' ♘ ', ' ♖ '],
      [' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ ', ' ♙ '],
      ['   ', '   ', '   ', ' ♟︎ ', '   ', ' ♟︎ ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', ' ♕ ', '   ', '   ', '   '],
      ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
      [' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ ', ' ♞ ', ' ♟︎ ', ' ♟︎ ', ' ♟︎ '],
      [' ♜ ', ' ♞ ', ' ♝ ', ' ♛ ', ' ♚ ', ' ♝ ', ' ♞ ', ' ♜ ']
    ]



def white_attacks(indexes)
  white = [' ♘ ', ' ♗ ', ' ♖ ', ' ♕ ', ' ♔ ']
  pawn = [' ♙ ']
  sub_round = 0

  2.times do
  sub_round += 1
    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      if white.include?(element)
        @white_moves.concat(@piece.check_piece(index, sub_round, @black_moves, @white_moves))
      elsif pawn.include?(element)
        @white_moves.concat(@piece.pawn_attacks(index, sub_round))
      end
    end
  end

  moves = @white_moves.uniq
end


def black_attacks(indexes)
  black = [' ♞ ', ' ♝ ', ' ♜ ', ' ♛ ', ' ♚ ']
  pawn = [' ♟︎ ']
  sub_round = 0

  2.times do
  sub_round += 1
    indexes.each do |index|
      row = index[0]
      col = index[1]
      element = @chessboard[row][col]
      if black.include?(element)
        @black_moves.concat(@piece.check_piece(index, sub_round, @black_moves, @white_moves))
      elsif pawn.include?(element)
        @black_moves.concat(@piece.pawn_attacks(index, sub_round))
      end
    end
  end

  moves = @black_moves.uniq
end