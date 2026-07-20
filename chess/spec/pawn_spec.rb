RSpec.describe Pawn do
  def build_board(*positions)
    board = Board.new
    (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
    positions.each { |pos, piece| board.set_piece(pos, piece) if piece }
    board
  end

  describe '#symbol' do
    it 'returns white pawn symbol' do
      expect(Pawn.new(:white, [1, 0]).symbol).to eq('♟')
    end

    it 'returns black pawn symbol' do
      expect(Pawn.new(:black, [6, 0]).symbol).to eq('♟')
    end
  end

  describe '#pseudo_legal_moves' do
    context 'with white pawn on starting rank' do
      let(:board) { build_board }
      let(:pawn) { Pawn.new(:white, [1, 0]) }

      before { board.set_piece([1, 0], pawn) }

      it 'can move one step forward' do
        expect(pawn.pseudo_legal_moves(board)).to include([2, 0])
      end

      it 'can move two steps forward from starting rank' do
        expect(pawn.pseudo_legal_moves(board)).to include([3, 0])
      end
    end

    context 'with blocked pawn' do
      let(:board) { build_board }
      let(:pawn) { Pawn.new(:white, [1, 0]) }

      before do
        board.set_piece([1, 0], pawn)
        board.set_piece([2, 0], Pawn.new(:black, [2, 0]))
      end

      it 'cannot move forward if blocked' do
        expect(pawn.pseudo_legal_moves(board)).not_to include([2, 0])
      end

      it 'cannot move two steps if one step is blocked' do
        expect(pawn.pseudo_legal_moves(board)).not_to include([3, 0])
      end
    end

    context 'two-step when first square empty but second blocked' do
      let(:board) { build_board }
      let(:pawn) { Pawn.new(:white, [1, 0]) }

      before do
        board.set_piece([1, 0], pawn)
        board.set_piece([3, 0], Pawn.new(:black, [3, 0]))
      end

      it 'can still move one step' do
        expect(pawn.pseudo_legal_moves(board)).to include([2, 0])
      end

      it 'cannot move two steps if destination is occupied' do
        expect(pawn.pseudo_legal_moves(board)).not_to include([3, 0])
      end
    end

    context 'with captures available' do
      let(:board) { build_board }
      let(:pawn) { Pawn.new(:white, [3, 3]) }

      before do
        board.set_piece([3, 3], pawn)
        board.set_piece([4, 4], Pawn.new(:black, [4, 4]))
        board.set_piece([4, 2], Pawn.new(:black, [4, 2]))
      end

      it 'can capture diagonally right' do
        expect(pawn.pseudo_legal_moves(board)).to include([4, 4])
      end

      it 'can capture diagonally left' do
        expect(pawn.pseudo_legal_moves(board)).to include([4, 2])
      end

      it 'can still move forward' do
        expect(pawn.pseudo_legal_moves(board)).to include([4, 3])
      end
    end

    context 'with friendly piece blocking diagonal' do
      let(:board) { build_board }
      let(:pawn) { Pawn.new(:white, [3, 3]) }

      before do
        board.set_piece([3, 3], pawn)
        board.set_piece([4, 4], Pawn.new(:white, [4, 4]))
      end

      it 'cannot capture friendly piece' do
        expect(pawn.pseudo_legal_moves(board)).not_to include([4, 4])
      end
    end

    context 'with black pawn' do
      let(:board) { build_board }
      let(:pawn) { Pawn.new(:black, [6, 0]) }

      before { board.set_piece([6, 0], pawn) }

      it 'moves in the correct direction' do
        expect(pawn.pseudo_legal_moves(board)).to include([5, 0])
      end

      it 'can move two steps from starting rank' do
        expect(pawn.pseudo_legal_moves(board)).to include([4, 0])
      end

      it 'can capture diagonally' do
        board.set_piece([5, 1], Pawn.new(:white, [5, 1]))
        expect(pawn.pseudo_legal_moves(board)).to include([5, 1])
      end
    end

    context 'at the edge of the board' do
      let(:board) { build_board }
      let(:pawn_a) { Pawn.new(:white, [3, 0]) }
      let(:pawn_h) { Pawn.new(:white, [3, 7]) }

      before do
        board.set_piece([3, 0], pawn_a)
        board.set_piece([3, 7], pawn_h)
      end

      it 'does not wrap on left edge' do
        expect(pawn_a.pseudo_legal_moves(board)).not_to include([4, -1])
      end

      it 'does not wrap on right edge' do
        expect(pawn_h.pseudo_legal_moves(board)).not_to include([4, 8])
      end
    end

    context 'at promotion rank' do
      it 'white pawn on rank 7 has no forward moves' do
        board = build_board
        pawn = Pawn.new(:white, [7, 0])
        board.set_piece([7, 0], pawn)
        expect(pawn.pseudo_legal_moves(board)).to be_empty
      end

      it 'black pawn on rank 0 has no forward moves' do
        board = build_board
        pawn = Pawn.new(:black, [0, 0])
        board.set_piece([0, 0], pawn)
        expect(pawn.pseudo_legal_moves(board)).to be_empty
      end
    end

    context 'all four corner captures' do
      let(:board) { build_board }

      it 'white pawn on a4 can capture only to b5 (not wrapping left)' do
        pawn = Pawn.new(:white, [3, 0])
        board.set_piece([3, 0], pawn)
        board.set_piece([4, 1], Pawn.new(:black, [4, 1]))
        moves = pawn.pseudo_legal_moves(board)
        expect(moves).to include([4, 1])
        expect(moves).not_to include([4, -1])
      end

      it 'white pawn on h4 can capture only to g5 (not wrapping right)' do
        pawn = Pawn.new(:white, [3, 7])
        board.set_piece([3, 7], pawn)
        board.set_piece([4, 6], Pawn.new(:black, [4, 6]))
        moves = pawn.pseudo_legal_moves(board)
        expect(moves).to include([4, 6])
        expect(moves).not_to include([4, 8])
      end
    end
  end
end
