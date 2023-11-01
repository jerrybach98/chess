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
    let(:chessboard) { 
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
    }

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

  describe 'bishop' do
    subject(:bishop) { described_class.new(board) }
    let(:board) { instance_double(Board) }
    let(:chessboard) { 
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
    }
    

    context 'when bishop is on array position 1, 1' do
      before do
        allow(board).to receive(:chessboard).and_return(chessboard)
      end

      it 'returns array of correct possible values' do
        bishop_coordinates = [1, 1]
        expect(bishop.bishop(bishop_coordinates)).to eq([[2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [2, 0], [0, 0], [0, 2]])
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