RSpec.describe 'moves.rb functions' do
  let(:board) { Board.new }

  def clear_board
    (0..7).each { |r| (0..7).each { |c| board.set_piece([r, c], nil) } }
  end

  describe '#incheckafter?' do
    it 'returns false for initial position' do
      expect(incheckafter?(board, :white)).to be false
      expect(incheckafter?(board, :black)).to be false
    end

    it 'returns true when king is in check' do
      clear_board
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([0, 0], Rook.new(:black, [0, 0]))
      expect(incheckafter?(board, :white)).to be true
    end

    it 'returns false when king is not in check' do
      clear_board
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([0, 0], Rook.new(:white, [0, 0]))
      expect(incheckafter?(board, :white)).to be false
    end

    context 'with a move parameter' do
      it 'detects that a blocking move resolves check' do
        clear_board
        board.set_piece([0, 4], King.new(:white, [0, 4]))
        board.set_piece([7, 4], King.new(:black, [7, 4]))
        board.set_piece([4, 4], Rook.new(:black, [4, 4]))
        board.set_piece([2, 4], Pawn.new(:white, [2, 4]))
        move = Move.new(from: [2, 4], to: [3, 4])
        expect(incheckafter?(board, :white, move)).to be false
      end

      it 'detects that a move still leaves king in check' do
        clear_board
        board.set_piece([0, 4], King.new(:white, [0, 4]))
        board.set_piece([0, 0], Rook.new(:black, [0, 0]))
        board.set_piece([1, 0], Pawn.new(:white, [1, 0]))
        move = Move.new(from: [1, 0], to: [2, 0])
        expect(incheckafter?(board, :white, move)).to be true
      end

      it 'properly restores captured pieces' do
        clear_board
        board.set_piece([0, 4], King.new(:white, [0, 4]))
        board.set_piece([0, 0], Rook.new(:black, [0, 0]))
        board.set_piece([3, 0], Pawn.new(:white, [3, 0]))
        board.set_piece([4, 0], Pawn.new(:black, [4, 0]))
        move = Move.new(from: [3, 0], to: [4, 0])
        incheckafter?(board, :white, move)
        expect(board.piece_at([3, 0])).to be_a(Pawn)
        expect(board.piece_at([3, 0]).color).to eq(:white)
        expect(board.piece_at([4, 0])).to be_a(Pawn)
        expect(board.piece_at([4, 0]).color).to eq(:black)
      end
    end
  end

  describe '#legal_moves' do
    it 'returns moves that do not leave own king in check' do
      clear_board
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([1, 4], Pawn.new(:white, [1, 4]))
      board.set_piece([3, 4], Pawn.new(:black, [3, 4]))
      board.set_piece([0, 0], Rook.new(:black, [0, 0]))
      pawn = board.piece_at([1, 4])
      moves = legal_moves(board, pawn)
      expect(moves).to all(be_a(Array))
    end

    it 'includes diagonal captures' do
      clear_board
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([1, 3], Pawn.new(:white, [1, 3]))
      board.set_piece([2, 4], Pawn.new(:black, [2, 4]))
      pawn = board.piece_at([1, 3])
      moves = legal_moves(board, pawn)
      expect(moves).to include([2, 4])
    end

    it 'excludes moves that would leave king in check (pinned piece)' do
      clear_board
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([1, 4], Bishop.new(:white, [1, 4]))
      board.set_piece([3, 4], Rook.new(:black, [3, 4]))
      bishop = board.piece_at([1, 4])
      moves = legal_moves(board, bishop)
      expect(moves).to all(be_a(Array))
      moves.each do |move|
        expect(incheckafter?(board, :white, Move.new(from: bishop.position, to: move))).to be false
      end
    end
  end

  describe '#legal_moves_color' do
    it 'returns all legal moves for all pieces of a color' do
      clear_board
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([0, 3], Queen.new(:white, [0, 3]))
      board.set_piece([7, 4], King.new(:black, [7, 4]))
      legal = legal_moves_color(board, :white)
      expect(legal).to all(be_a(Array))
    end

    it 'returns empty when in checkmate' do
      clear_board
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([7, 4], King.new(:black, [7, 4]))
      board.set_piece([1, 4], Rook.new(:black, [1, 4]))
      board.set_piece([1, 3], Rook.new(:black, [1, 3]))
      board.set_piece([1, 5], Rook.new(:black, [1, 5]))
      expect(legal_moves_color(board, :white)).to be_empty
    end
  end

  describe '#can_castle' do
    before do
      clear_board
    end

    let(:white_king) { King.new(:white, [0, 4]) }
    let(:white_rook_k) { Rook.new(:white, [0, 7]) }
    let(:white_rook_q) { Rook.new(:white, [0, 0]) }
    let(:black_king) { King.new(:black, [7, 4]) }
    let(:black_rook_k) { Rook.new(:black, [7, 7]) }
    let(:black_rook_q) { Rook.new(:black, [7, 0]) }

    def setup_kingside(color)
      rank = color == :white ? 0 : 7
      king = King.new(color, [rank, 4])
      rook = Rook.new(color, [rank, 7])
      board.set_piece([rank, 4], king)
      board.set_piece([rank, 5], nil)
      board.set_piece([rank, 6], nil)
      board.set_piece([rank, 7], rook)
      king
    end

    def setup_queenside(color)
      rank = color == :white ? 0 : 7
      king = King.new(color, [rank, 4])
      rook = Rook.new(color, [rank, 0])
      board.set_piece([rank, 4], king)
      board.set_piece([rank, 3], nil)
      board.set_piece([rank, 2], nil)
      board.set_piece([rank, 1], nil)
      board.set_piece([rank, 0], rook)
      king
    end

    context 'kingside' do
      it 'allows kingside castling when clear' do
        setup_kingside(:white)
        expect(can_castle(board, :white, :short)).to be true
      end

      it 'rejects if pieces between king and rook' do
        setup_kingside(:white)
        board.set_piece([0, 5], Pawn.new(:white, [0, 5]))
        expect(can_castle(board, :white, :short)).to be false
      end

      it 'rejects if king has moved' do
        king = setup_kingside(:white)
        king.has_moved = true
        expect(can_castle(board, :white, :short)).to be false
      end

      it 'rejects if rook has moved' do
        setup_kingside(:white)
        rook = board.piece_at([0, 7])
        rook.has_moved = true
        expect(can_castle(board, :white, :short)).to be false
      end

      it 'rejects if king is in check' do
        setup_kingside(:white)
        board.set_piece([3, 4], Rook.new(:black, [3, 4]))
        expect(can_castle(board, :white, :short)).to be false
      end

      it 'rejects if king passes through check' do
        setup_kingside(:white)
        board.set_piece([3, 5], Rook.new(:black, [3, 5]))
        expect(can_castle(board, :white, :short)).to be false
      end
    end

    context 'queenside' do
      it 'allows queenside castling when clear' do
        setup_queenside(:white)
        expect(can_castle(board, :white, :long)).to be true
      end

      it 'rejects if pieces between king and rook' do
        setup_queenside(:white)
        board.set_piece([0, 1], Pawn.new(:white, [0, 1]))
        expect(can_castle(board, :white, :long)).to be false
      end

      it 'rejects if king passes through check' do
        setup_queenside(:white)
        board.set_piece([3, 3], Rook.new(:black, [3, 3]))
        expect(can_castle(board, :white, :long)).to be false
      end
    end

    context 'black' do
      it 'allows black kingside castling' do
        setup_kingside(:black)
        expect(can_castle(board, :black, :short)).to be true
      end

      it 'allows black queenside castling' do
        setup_queenside(:black)
        expect(can_castle(board, :black, :long)).to be true
      end
    end
  end

  describe '#castle' do
    before do
      clear_board
    end

    it 'performs kingside castling for white' do
      king = King.new(:white, [0, 4])
      rook = Rook.new(:white, [0, 7])
      board.set_piece([0, 4], king)
      board.set_piece([0, 7], rook)
      castle(board, :white, :short)
      expect(board.piece_at([0, 6])).to be_a(King)
      expect(board.piece_at([0, 5])).to be_a(Rook)
      expect(board.piece_at([0, 4])).to be_nil
      expect(board.piece_at([0, 7])).to be_nil
    end

    it 'performs queenside castling for white' do
      king = King.new(:white, [0, 4])
      rook = Rook.new(:white, [0, 0])
      board.set_piece([0, 4], king)
      board.set_piece([0, 0], rook)
      castle(board, :white, :long)
      expect(board.piece_at([0, 2])).to be_a(King)
      expect(board.piece_at([0, 3])).to be_a(Rook)
      expect(board.piece_at([0, 4])).to be_nil
      expect(board.piece_at([0, 0])).to be_nil
    end

    it 'marks king and rook as moved' do
      king = King.new(:white, [0, 4])
      rook = Rook.new(:white, [0, 0])
      board.set_piece([0, 4], king)
      board.set_piece([0, 0], rook)
      castle(board, :white, :long)
      expect(king.has_moved).to be true
      expect(rook.has_moved).to be true
    end
  end

  describe '#handle_enpassant' do
    before { clear_board }

    it 'performs en passant capture' do
      white_pawn = Pawn.new(:white, [4, 3])
      black_pawn = Pawn.new(:black, [4, 4])
      board.set_piece([4, 3], white_pawn)
      board.set_piece([4, 4], black_pawn)
      last_move = Move.new
      last_move.from = [6, 4]
      last_move.to = [4, 4]
      last_move.piece = black_pawn
      move = Move.new
      move.from = [4, 3]
      move.to = [5, 4]
      result = handle_enpassant(board, move, last_move, white_pawn)
      expect(result).to be true
      expect(board.piece_at([5, 4])).to be(white_pawn)
      expect(board.piece_at([4, 4])).to be_nil
      expect(board.piece_at([4, 3])).to be_nil
    end

    it 'rejects if last_move is not a double-step pawn push' do
      white_pawn = Pawn.new(:white, [4, 3])
      black_pawn = Pawn.new(:black, [5, 4])
      board.set_piece([4, 3], white_pawn)
      board.set_piece([5, 4], black_pawn)
      last_move = Move.new
      last_move.from = [6, 4]
      last_move.to = [5, 4]
      last_move.piece = black_pawn
      move = Move.new
      move.from = [4, 3]
      move.to = [5, 4]
      result = handle_enpassant(board, move, last_move, white_pawn)
      expect(result).to be false
    end

    it 'updates piece.position after capture' do
      white_pawn = Pawn.new(:white, [4, 3])
      black_pawn = Pawn.new(:black, [4, 4])
      board.set_piece([4, 3], white_pawn)
      board.set_piece([4, 4], black_pawn)
      last_move = Move.new
      last_move.from = [6, 4]
      last_move.to = [4, 4]
      last_move.piece = black_pawn
      move = Move.new
      move.from = [4, 3]
      move.to = [5, 4]
      handle_enpassant(board, move, last_move, white_pawn)
      expect(white_pawn.position).to eq([5, 4])
    end
  end

  describe '#apply_move' do
    before { clear_board }

    it 'applies a simple move' do
      board.set_piece([1, 0], Pawn.new(:white, [1, 0]))
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([7, 4], King.new(:black, [7, 4]))
      move = Move.new
      move.from = [1, 0]
      move.to = [2, 0]
      success, result_move = apply_move(board, move, :white)
      expect(success).to be true
      expect(board.piece_at([2, 0])).to be_a(Pawn)
      expect(board.piece_at([1, 0])).to be_nil
    end

    it 'rejects an illegal pawn move (3 steps)' do
      clear_board
      board.set_piece([1, 0], Pawn.new(:white, [1, 0]))
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([7, 4], King.new(:black, [7, 4]))
      move = Move.new
      move.from = [1, 0]
      move.to = [4, 0]
      success, = apply_move(board, move, :white)
      expect(success).to be false
    end

    it 'handles castling' do
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([0, 7], Rook.new(:white, [0, 7]))
      board.set_piece([7, 4], King.new(:black, [7, 4]))
      move = Move.new
      move.castle = :short
      success, = apply_move(board, move, :white)
      expect(success).to be true
      expect(board.piece_at([0, 6])).to be_a(King)
    end

    it 'handles promotion' do
      board.set_piece([6, 0], Pawn.new(:white, [6, 0]))
      board.set_piece([0, 4], King.new(:white, [0, 4]))
      board.set_piece([7, 4], King.new(:black, [7, 4]))
      move = Move.new
      move.from = [6, 0]
      move.to = [7, 0]
      move.promotion = :queen
      success, = apply_move(board, move, :white)
      expect(success).to be true
      expect(board.piece_at([7, 0])).to be_a(Queen)
    end

    it 'sets check flag when delivering check' do
      clear_board
      board.set_piece([0, 0], King.new(:white, [0, 0]))
      board.set_piece([7, 4], King.new(:black, [7, 4]))
      board.set_piece([5, 4], Rook.new(:white, [5, 4]))
      move = Move.new
      move.from = [5, 4]
      move.to = [6, 4]
      success, result_move = apply_move(board, move, :white)
      expect(success).to be true
      expect(result_move.check).to be true
    end
  end
end
