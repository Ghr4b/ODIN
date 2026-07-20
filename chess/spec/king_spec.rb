RSpec.describe King do
  def build_board
    board = Board.new
    (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
    board
  end

  describe '#symbol' do
    it 'returns white king symbol' do
      expect(King.new(:white, [0, 4]).symbol).to eq('♚')
    end

    it 'returns black king symbol' do
      expect(King.new(:black, [7, 4]).symbol).to eq('♚')
    end
  end

  describe '#has_moved' do
    it 'initializes to false' do
      expect(King.new(:white, [0, 4]).has_moved).to be false
    end

    it 'can be set to true' do
      king = King.new(:white, [0, 4])
      king.has_moved = true
      expect(king.has_moved).to be true
    end
  end

  describe '#pseudo_legal_moves' do
    context 'on an empty board' do
      let(:board) { build_board }
      let(:king) { King.new(:white, [3, 3]) }

      before { board.set_piece([3, 3], king) }

      it 'has 8 moves from the center' do
        expect(king.pseudo_legal_moves(board).size).to eq(8)
      end

      it 'includes all adjacent squares' do
        expected = [
          [2, 2], [2, 3], [2, 4],
          [3, 2],         [3, 4],
          [4, 2], [4, 3], [4, 4]
        ]
        expect(king.pseudo_legal_moves(board)).to match_array(expected)
      end
    end

    context 'on the edge of the board' do
      let(:board) { build_board }
      let(:king) { King.new(:white, [0, 0]) }

      before { board.set_piece([0, 0], king) }

      it 'has 3 moves from a corner' do
        expect(king.pseudo_legal_moves(board).size).to eq(3)
      end

      it 'includes only valid squares' do
        expect(king.pseudo_legal_moves(board)).to match_array([[0, 1], [1, 0], [1, 1]])
      end
    end

    context 'blocked by friendly pieces' do
      let(:board) { build_board }
      let(:king) { King.new(:white, [3, 3]) }

      before do
        board.set_piece([3, 3], king)
        board.set_piece([2, 3], Pawn.new(:white, [2, 3]))
        board.set_piece([3, 4], Pawn.new(:white, [3, 4]))
      end

      it 'cannot move onto friendly squares' do
        moves = king.pseudo_legal_moves(board)
        expect(moves).not_to include([2, 3])
        expect(moves).not_to include([3, 4])
      end

      it 'can still capture enemy pieces' do
        board.set_piece([4, 4], Pawn.new(:black, [4, 4]))
        expect(king.pseudo_legal_moves(board)).to include([4, 4])
      end
    end
  end
end
