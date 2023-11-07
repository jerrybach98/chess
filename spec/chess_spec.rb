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
        expect(king.king(king_coordinates, round)).to eq([[1, 4], [1, 5], [0, 3], [1, 3]])
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

