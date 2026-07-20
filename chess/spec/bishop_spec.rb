RSpec.describe Bishop do
  def build_board
    board = Board.new
    (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
    board
  end

  describe '#symbol' do
    it 'returns white bishop symbol' do
      expect(Bishop.new(:white, [0, 2]).symbol).to eq('♝')
    end

    it 'returns black bishop symbol' do
      expect(Bishop.new(:black, [7, 2]).symbol).to eq('♝')
    end
  end

  describe '#pseudo_legal_moves' do
    context 'in the center of an empty board' do
      let(:board) { build_board }
      let(:bishop) { Bishop.new(:white, [3, 3]) }

      before { board.set_piece([3, 3], bishop) }

      it 'has 13 diagonal moves' do
        expect(bishop.pseudo_legal_moves(board).size).to eq(13)
      end

      it 'includes moves in all four diagonal directions' do
        moves = bishop.pseudo_legal_moves(board)
        expect(moves).to include([4, 4], [5, 5], [6, 6], [7, 7])
        expect(moves).to include([4, 2], [5, 1], [6, 0])
        expect(moves).to include([2, 4], [1, 5], [0, 6])
        expect(moves).to include([2, 2], [1, 1], [0, 0])
      end
    end

    context 'when blocked by friendly piece' do
      let(:board) { build_board }
      let(:bishop) { Bishop.new(:white, [3, 3]) }

      before do
        board.set_piece([3, 3], bishop)
        board.set_piece([5, 5], Pawn.new(:white, [5, 5]))
      end

      it 'cannot move past friendly piece' do
        moves = bishop.pseudo_legal_moves(board)
        expect(moves).to include([4, 4])
        expect(moves).not_to include([5, 5])
        expect(moves).not_to include([6, 6])
      end
    end

    context 'when capturing' do
      let(:board) { build_board }
      let(:bishop) { Bishop.new(:white, [3, 3]) }

      before do
        board.set_piece([3, 3], bishop)
        board.set_piece([5, 5], Pawn.new(:black, [5, 5]))
      end

      it 'can capture enemy piece' do
        moves = bishop.pseudo_legal_moves(board)
        expect(moves).to include([5, 5])
      end

      it 'stops after capturing' do
        moves = bishop.pseudo_legal_moves(board)
        expect(moves).not_to include([6, 6])
      end
    end
  end
end
