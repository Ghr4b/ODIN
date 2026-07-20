RSpec.describe Board do
  subject(:board) { Board.new }

  describe '#initialize' do
    it 'creates 64 squares' do
      expect(board.instance_variable_get(:@squares).size).to eq(64)
    end

    it 'sets up the starting position' do
      expect(board.piece_at([0, 4])).to be_a(King)
      expect(board.piece_at([0, 3])).to be_a(Queen)
      expect(board.piece_at([1, 0])).to be_a(Pawn)
      expect(board.piece_at([7, 4])).to be_a(King)
      expect(board.piece_at([7, 3])).to be_a(Queen)
      expect(board.piece_at([6, 0])).to be_a(Pawn)
    end
  end

  describe '#piece_at' do
    it 'returns nil for empty square' do
      expect(board.piece_at([3, 3])).to be_nil
    end

    it 'returns the piece at the given position' do
      expect(board.piece_at([0, 0])).to be_a(Rook)
    end
  end

  describe '#set_piece' do
    it 'places a piece on the board' do
      pawn = Pawn.new(:white, [3, 3])
      board.set_piece([3, 3], pawn)
      expect(board.piece_at([3, 3])).to eq(pawn)
    end

    it 'removes a piece when set to nil' do
      board.set_piece([0, 0], nil)
      expect(board.piece_at([0, 0])).to be_nil
    end
  end

  describe '#empty?' do
    it 'returns true for empty square' do
      expect(board.empty?([3, 3])).to be true
    end

    it 'returns false for occupied square' do
      expect(board.empty?([0, 0])).to be false
    end
  end

  describe '#move' do
    it 'moves a piece from one square to another' do
      king = board.piece_at([0, 4])
      board.move([0, 4], [1, 4])
      expect(board.piece_at([1, 4])).to eq(king)
      expect(board.piece_at([0, 4])).to be_nil
    end

    it 'updates the pieces position' do
      pawn = board.piece_at([1, 0])
      board.move([1, 0], [2, 0])
      expect(pawn.position).to eq([2, 0])
    end

    it 'captures an enemy piece' do
      board.set_piece([3, 0], Pawn.new(:black, [3, 0]))
      board.set_piece([4, 0], Pawn.new(:white, [4, 0]))
      captured = board.move([4, 0], [3, 0])
      expect(captured).to be_a(Pawn)
      expect(captured.color).to eq(:black)
    end

    it 'returns nil when no piece at from' do
      expect(board.move([3, 3], [4, 4])).to be_nil
    end

    it 'tracks has_moved for King via moves counter' do
      king = board.piece_at([0, 4])
      king.moves = 1
      expect(king.has_moved?).to be true
      king.moves = 0
      expect(king.has_moved?).to be false
    end

    it 'tracks has_moved for Rook via moves counter' do
      rook = board.piece_at([0, 0])
      rook.moves = 1
      expect(rook.has_moved?).to be true
      rook.moves = 0
      expect(rook.has_moved?).to be false
    end
  end

  describe '#all_pieces' do
    it 'returns all white pieces' do
      expect(board.all_pieces(:white).size).to eq(16)
    end

    it 'returns all black pieces' do
      expect(board.all_pieces(:black).size).to eq(16)
    end

    it 'returns pieces of the correct color' do
      expect(board.all_pieces(:white)).to all(have_attributes(color: :white))
    end
  end

  describe '#find_king' do
    it 'finds white king index' do
      index = board.find_king(:white)
      expect(index).to be_a(Integer)
      expect(board.instance_variable_get(:@squares)[index]).to be_a(King)
    end

    it 'returns nil when king is missing' do
      board.set_piece([0, 4], nil)
      expect(board.find_king(:white)).to be_nil
    end
  end

  describe '#incheck?' do
    it 'returns false in initial position' do
      expect(board.incheck?(:white)).to be false
      expect(board.incheck?(:black)).to be false
    end

    it 'detects check by rook' do
      board.set_piece([0, 4], nil)
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([0, 0], nil)
      board.set_piece([0, 3], Rook.new(:black, [0, 3]))
      expect(board.incheck?(:white)).to be true
    end

    it 'detects check by bishop' do
      (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([7, 4], King.new(:black, [7, 4]))
      board.set_piece([4, 0], Bishop.new(:black, [4, 0]))
      expect(board.incheck?(:white)).to be true
    end

    it 'detects check by knight' do
      board.set_piece([0, 4], nil)
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([2, 5], Knight.new(:black, [2, 5]))
      expect(board.incheck?(:white)).to be true
    end
  end

  describe '#incheckmate?' do
    it 'returns false in initial position' do
      expect(board.incheckmate?(:white)).to be false
    end

    it 'detects back-rank checkmate' do
      (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([7, 4], King.new(:black, [7, 4]))
      board.set_piece([1, 4], Rook.new(:black, [1, 4]))
      board.set_piece([1, 3], Rook.new(:black, [1, 3]))
      board.set_piece([1, 5], Rook.new(:black, [1, 5]))
      expect(board.incheckmate?(:white)).to be true
    end
  end

  describe '#stalemate?' do
    it 'returns false in initial position' do
      expect(board.stalemate?(:white)).to be false
    end

    it 'detects stalemate' do
      (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
      board.set_piece([0, 0], King.new(:white, [0, 0]))
      board.set_piece([1, 2], Queen.new(:black, [1, 2]))
      board.set_piece([2, 1], Rook.new(:black, [2, 1]))
      expect(board.stalemate?(:white)).to be true
    end
  end

  describe '#handle_promotion' do
    before do
      (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
    end

    it 'promotes to queen by default' do
      board.set_piece([7, 0], Pawn.new(:white, [7, 0]))
      board.handle_promotion([7, 0], :queen, :white)
      expect(board.piece_at([7, 0])).to be_a(Queen)
      expect(board.piece_at([7, 0]).color).to eq(:white)
    end

    it 'promotes to rook' do
      board.set_piece([7, 0], Pawn.new(:white, [7, 0]))
      board.handle_promotion([7, 0], :rook, :white)
      expect(board.piece_at([7, 0])).to be_a(Rook)
    end

    it 'promotes to bishop' do
      board.set_piece([7, 0], Pawn.new(:white, [7, 0]))
      board.handle_promotion([7, 0], :bishop, :white)
      expect(board.piece_at([7, 0])).to be_a(Bishop)
    end

    it 'promotes to knight' do
      board.set_piece([7, 0], Pawn.new(:white, [7, 0]))
      board.handle_promotion([7, 0], :knight, :white)
      expect(board.piece_at([7, 0])).to be_a(Knight)
    end

    it 'promotes black pawn' do
      board.set_piece([0, 0], Pawn.new(:black, [0, 0]))
      board.handle_promotion([0, 0], :queen, :black)
      expect(board.piece_at([0, 0]).color).to eq(:black)
    end
  end

  describe '#square_to_coord' do
    it 'converts a1 to [0, 0]' do
      expect(board.square_to_coord('a1')).to eq([0, 0])
    end

    it 'converts h8 to [7, 7]' do
      expect(board.square_to_coord('h8')).to eq([7, 7])
    end

    it 'converts e4 to [3, 4]' do
      expect(board.square_to_coord('e4')).to eq([3, 4])
    end

    it 'returns nil for invalid input' do
      expect(board.square_to_coord('z9')).to be_nil
    end

    it 'converts uppercase' do
      expect(board.square_to_coord('A1')).to eq([0, 0])
    end
  end

  describe '#undo_move' do
    it 'restores pieces' do
      white_pawn = board.piece_at([1, 0])
      black_pawn = board.piece_at([6, 0])
      move = Move.new
      move.from = [1, 0]
      move.to = [3, 0]
      move.piece = white_pawn
      move.capture = nil

      board.move([1, 0], [3, 0])
      board.undo_move(move)

      expect(board.piece_at([1, 0])).to eq(white_pawn)
      expect(board.piece_at([3, 0])).to be_nil
    end
  end

  describe '#display' do
    it 'outputs the board' do
      expect { board.display }.to output.to_stdout
    end
  end
end
