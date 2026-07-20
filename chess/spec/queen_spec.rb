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

    context 'in a corner' do
      let(:board) { build_board }

      it 'has 21 moves from corner [0,0]' do
        queen = Queen.new(:white, [0, 0])
        board.set_piece([0, 0], queen)
        expect(queen.pseudo_legal_moves(board).size).to eq(21)
      end

      it 'has 21 moves from corner [0,7]' do
        queen = Queen.new(:white, [0, 7])
        board.set_piece([0, 7], queen)
        expect(queen.pseudo_legal_moves(board).size).to eq(21)
      end

      it 'has 21 moves from corner [7,7]' do
        queen = Queen.new(:black, [7, 7])
        board.set_piece([7, 7], queen)
        expect(queen.pseudo_legal_moves(board).size).to eq(21)
      end
    end

    context 'completely surrounded' do
      let(:board) { build_board }
      let(:queen) { Queen.new(:white, [3, 3]) }

      before do
        board.set_piece([3, 3], queen)
        [[2,2],[2,3],[2,4],[3,2],[3,4],[4,2],[4,3],[4,4]].each do |pos|
          board.set_piece(pos, Pawn.new(:white, pos))
        end
      end

      it 'has 0 moves when surrounded by friendlies' do
        expect(queen.pseudo_legal_moves(board)).to be_empty
      end

      it 'has 8 moves when surrounded by enemies (all captures)' do
        board.set_piece([2,2], Pawn.new(:black, [2,2]))
        board.set_piece([2,3], Pawn.new(:black, [2,3]))
        board.set_piece([2,4], Pawn.new(:black, [2,4]))
        board.set_piece([3,2], Pawn.new(:black, [3,2]))
        board.set_piece([3,4], Pawn.new(:black, [3,4]))
        board.set_piece([4,2], Pawn.new(:black, [4,2]))
        board.set_piece([4,3], Pawn.new(:black, [4,3]))
        board.set_piece([4,4], Pawn.new(:black, [4,4]))
        expect(queen.pseudo_legal_moves(board).size).to eq(8)
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
