RSpec.describe Knight do
  def build_board
    board = Board.new
    (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
    board
  end

  describe '#symbol' do
    it 'returns white knight symbol' do
      expect(Knight.new(:white, [0, 1]).symbol).to eq('♞')
    end

    it 'returns black knight symbol' do
      expect(Knight.new(:black, [7, 1]).symbol).to eq('♞')
    end
  end

  describe '#pseudo_legal_moves' do
    context 'in the center' do
      let(:board) { build_board }
      let(:knight) { Knight.new(:white, [3, 3]) }

      before { board.set_piece([3, 3], knight) }

      it 'has 8 L-shaped moves' do
        expect(knight.pseudo_legal_moves(board).size).to eq(8)
      end

      it 'includes all valid knight destinations' do
        expected = [
          [1, 2], [1, 4],
          [2, 1], [2, 5],
          [4, 1], [4, 5],
          [5, 2], [5, 4]
        ]
        expect(knight.pseudo_legal_moves(board)).to match_array(expected)
      end

      context 'with all 8 squares occupied by friendlies' do
        before do
          [[1,2],[1,4],[2,1],[2,5],[4,1],[4,5],[5,2],[5,4]].each do |pos|
            board.set_piece(pos, Pawn.new(:white, pos))
          end
        end

        it 'has 0 moves' do
          expect(knight.pseudo_legal_moves(board)).to be_empty
        end
      end

      context 'with all 8 squares occupied by enemies' do
        before do
          [[1,2],[1,4],[2,1],[2,5],[4,1],[4,5],[5,2],[5,4]].each do |pos|
            board.set_piece(pos, Pawn.new(:black, pos))
          end
        end

        it 'can capture all 8' do
          expect(knight.pseudo_legal_moves(board).size).to eq(8)
        end
      end
    end

    context 'in a corner' do
      let(:board) { build_board }

      it 'has 2 moves from corner [0,0]' do
        knight = Knight.new(:white, [0, 0])
        board.set_piece([0, 0], knight)
        expect(knight.pseudo_legal_moves(board)).to match_array([[1, 2], [2, 1]])
      end

      it 'has 4 moves from corner [0,7]' do
        knight = Knight.new(:white, [0, 7])
        board.set_piece([0, 7], knight)
        expect(knight.pseudo_legal_moves(board)).to match_array([[1, 5], [2, 6]])
      end

      it 'has 4 moves from corner [7,0]' do
        knight = Knight.new(:black, [7, 0])
        board.set_piece([7, 0], knight)
        expect(knight.pseudo_legal_moves(board)).to match_array([[5, 1], [6, 2]])
      end

      it 'has 2 moves from corner [7,7]' do
        knight = Knight.new(:black, [7, 7])
        board.set_piece([7, 7], knight)
        expect(knight.pseudo_legal_moves(board)).to match_array([[5, 6], [6, 5]])
      end
    end

    it 'can jump over pieces' do
      board = build_board
      knight = Knight.new(:white, [3, 3])
      board.set_piece([3, 3], knight)
      board.set_piece([2, 3], Pawn.new(:white, [2, 3]))
      board.set_piece([3, 4], Pawn.new(:black, [3, 4]))
      expect(knight.pseudo_legal_moves(board).size).to eq(8)
    end

    it 'can capture enemy pieces' do
      board = build_board
      knight = Knight.new(:white, [3, 3])
      board.set_piece([3, 3], knight)
      board.set_piece([4, 5], Pawn.new(:black, [4, 5]))
      expect(knight.pseudo_legal_moves(board)).to include([4, 5])
    end
  end
end
