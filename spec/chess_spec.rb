require './lib/main'

describe Player do
  describe '#select_position' do
    context 'when player provides a correct board position' do
      subject(:player) { described_class.new(board) }
      let(:board) { instance_double(Board) }

      before do
        # allow(players).to receive(:puts)
        allow(player).to receive(:gets).and_return('a2')
      end

      it 'returns the correct position' do
        expect(player.select_position).to eq('a2')
      end
    end

    context 'when player provides an incorrect then correct board position' do
      subject(:player) { described_class.new(board) }
      let(:board) { instance_double(Board) }

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
    subject(:input) { described_class.new(board) }
    let(:board) { instance_double(Board) }

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