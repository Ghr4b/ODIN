RSpec.describe Rook do
  def build_board
    board = Board.new
    (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
    board
  end

  describe '#symbol' do
    it 'returns white rook symbol' do
      expect(Rook.new(:white, [0, 0]).symbol).to eq('♜')
    end

    it 'returns black rook symbol' do
      expect(Rook.new(:black, [7, 0]).symbol).to eq('♜')
    end
  end

  describe '#has_moved' do
    it 'initializes to false' do
      expect(Rook.new(:white, [0, 0]).has_moved?).to be false
    end
  end

  describe '#pseudo_legal_moves' do
    context 'in the center of an empty board' do
      let(:board) { build_board }
      let(:rook) { Rook.new(:white, [3, 3]) }

      before { board.set_piece([3, 3], rook) }

      it 'has 14 straight moves' do
        expect(rook.pseudo_legal_moves(board).size).to eq(14)
      end

      it 'moves in all four straight directions' do
        moves = rook.pseudo_legal_moves(board)
        expect(moves).to include([4, 3], [5, 3], [6, 3], [7, 3])
        expect(moves).to include([2, 3], [1, 3], [0, 3])
        expect(moves).to include([3, 4], [3, 5], [3, 6], [3, 7])
        expect(moves).to include([3, 2], [3, 1], [3, 0])
      end
    end

    context 'when blocked' do
      let(:board) { build_board }
      let(:rook) { Rook.new(:white, [3, 3]) }

      before do
        board.set_piece([3, 3], rook)
        board.set_piece([5, 3], Pawn.new(:white, [5, 3]))
      end

      it 'cannot move past friendly piece' do
        moves = rook.pseudo_legal_moves(board)
        expect(moves).to include([4, 3])
        expect(moves).not_to include([5, 3])
      end
    end

    it 'can capture enemy piece and stop' do
      board = build_board
      rook = Rook.new(:white, [3, 3])
      board.set_piece([3, 3], rook)
      board.set_piece([5, 3], Pawn.new(:black, [5, 3]))
      moves = rook.pseudo_legal_moves(board)
      expect(moves).to include([5, 3])
      expect(moves).not_to include([6, 3])
    end
  end
end
