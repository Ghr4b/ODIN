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
    end

    context 'in a corner' do
      let(:board) { build_board }
      let(:knight) { Knight.new(:white, [0, 0]) }

      before { board.set_piece([0, 0], knight) }

      it 'has 2 moves from corner' do
        expect(knight.pseudo_legal_moves(board).size).to eq(2)
      end

      it 'jumps to correct squares' do
        expect(knight.pseudo_legal_moves(board)).to match_array([[1, 2], [2, 1]])
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
