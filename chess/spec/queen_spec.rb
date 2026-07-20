RSpec.describe Queen do
  def build_board
    board = Board.new
    (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
    board
  end

  describe '#symbol' do
    it 'returns white queen symbol' do
      expect(Queen.new(:white, [0, 3]).symbol).to eq('♛')
    end

    it 'returns black queen symbol' do
      expect(Queen.new(:black, [7, 3]).symbol).to eq('♛')
    end
  end

  describe '#pseudo_legal_moves' do
    context 'in the center of an empty board' do
      let(:board) { build_board }
      let(:queen) { Queen.new(:white, [3, 3]) }

      before { board.set_piece([3, 3], queen) }

      it 'has 27 moves (13 diagonal + 14 straight)' do
        expect(queen.pseudo_legal_moves(board).size).to eq(27)
      end

      it 'includes both diagonal and straight moves' do
        moves = queen.pseudo_legal_moves(board)
        expect(moves).to include([4, 4], [7, 7])
        expect(moves).to include([4, 3], [7, 3])
      end
    end

    context 'when blocked' do
      let(:board) { build_board }
      let(:queen) { Queen.new(:white, [3, 3]) }

      before do
        board.set_piece([3, 3], queen)
        board.set_piece([5, 5], Pawn.new(:white, [5, 5]))
        board.set_piece([3, 6], Pawn.new(:black, [3, 6]))
      end

      it 'stops before friendly piece' do
        moves = queen.pseudo_legal_moves(board)
        expect(moves).to include([4, 4])
        expect(moves).not_to include([5, 5])
      end

      it 'captures enemy piece and stops' do
        moves = queen.pseudo_legal_moves(board)
        expect(moves).to include([3, 6])
        expect(moves).not_to include([3, 7])
      end
    end
  end
end
