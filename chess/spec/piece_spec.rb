RSpec.describe Piece do
  subject(:piece) { described_class.new(:white, [3, 3]) }

  describe '#initialize' do
    it 'sets color' do
      expect(piece.color).to eq(:white)
    end

    it 'sets position' do
      expect(piece.position).to eq([3, 3])
    end
  end

  describe '#enemy?' do
    let(:ally) { double('ally', color: :white) }
    let(:foe) { double('foe', color: :black) }

    it 'returns true for enemy piece' do
      expect(piece.enemy?(foe)).to be true
    end

    it 'returns false for friendly piece' do
      expect(piece.enemy?(ally)).to be false
    end

    it 'returns false for nil' do
      expect(piece.enemy?(nil)).to be false
    end
  end

  describe '#friendly?' do
    let(:ally) { double('ally', color: :white) }
    let(:foe) { double('foe', color: :black) }

    it 'returns true for friendly piece' do
      expect(piece.friendly?(ally)).to be true
    end

    it 'returns false for enemy piece' do
      expect(piece.friendly?(foe)).to be false
    end

    it 'returns false for nil' do
      expect(piece.friendly?(nil)).to be false
    end
  end

  describe '#symbol' do
    it 'raises NotImplementedError' do
      expect { piece.symbol }.to raise_error(NotImplementedError)
    end
  end

  describe '#pseudo_legal_moves' do
    it 'raises NotImplementedError' do
      expect { piece.pseudo_legal_moves(nil) }.to raise_error(NotImplementedError)
    end
  end
end
