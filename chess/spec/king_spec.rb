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

  describe '#moves counter' do
    it 'initializes to 0' do
      expect(King.new(:white, [0, 4]).moves).to eq(0)
    end
  end

  describe '#has_moved' do
    it 'initializes to false' do
      expect(King.new(:white, [0, 4]).has_moved?).to be false
    end

    it 'can be set to true' do
      king = King.new(:white, [0, 4])
      king.moves = 1
      expect(king.has_moved?).to be true
    end

    it 'is true when moves > 1' do
      king = King.new(:white, [0, 4])
      king.moves = 2
      expect(king.has_moved?).to be true
    end

    it 'returns false after decrementing moves back to 0' do
      king = King.new(:white, [0, 4])
      king.moves = 1
      king.moves -= 1
      expect(king.has_moved?).to be false
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

      context 'surrounded by all enemies' do
        before do
          [[2,2],[2,3],[2,4],[3,2],[3,4],[4,2],[4,3],[4,4]].each do |pos|
            board.set_piece(pos, Pawn.new(:black, pos))
          end
        end

        it 'can capture all 8' do
          expect(king.pseudo_legal_moves(board).size).to eq(8)
        end
      end

      context 'surrounded by all friendlies' do
        before do
          [[2,2],[2,3],[2,4],[3,2],[3,4],[4,2],[4,3],[4,4]].each do |pos|
            board.set_piece(pos, Pawn.new(:white, pos))
          end
        end

        it 'has 0 moves' do
          expect(king.pseudo_legal_moves(board)).to be_empty
        end
      end
    end

    context 'on the edge of the board' do
      let(:board) { build_board }

      it 'has 3 moves from corner [0,0]' do
        king = King.new(:white, [0, 0])
        board.set_piece([0, 0], king)
        expect(king.pseudo_legal_moves(board)).to match_array([[0, 1], [1, 0], [1, 1]])
      end

      it 'has 3 moves from corner [0,7]' do
        king = King.new(:white, [0, 7])
        board.set_piece([0, 7], king)
        expect(king.pseudo_legal_moves(board)).to match_array([[0, 6], [1, 6], [1, 7]])
      end

      it 'has 3 moves from corner [7,0]' do
        king = King.new(:black, [7, 0])
        board.set_piece([7, 0], king)
        expect(king.pseudo_legal_moves(board)).to match_array([[6, 0], [6, 1], [7, 1]])
      end

      it 'has 3 moves from corner [7,7]' do
        king = King.new(:black, [7, 7])
        board.set_piece([7, 7], king)
        expect(king.pseudo_legal_moves(board)).to match_array([[6, 6], [6, 7], [7, 6]])
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
