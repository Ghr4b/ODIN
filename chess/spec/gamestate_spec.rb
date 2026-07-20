RSpec.describe GameState do
  subject(:game) { GameState.new }

  describe '#initialize' do
    it 'creates a board' do
      expect(game.board).to be_a(Board)
    end

    it 'sets current player to white' do
      expect(game.current_player).to eq(:white)
    end

    it 'initializes empty history' do
      expect(game.instance_variable_get(:@history)).to eq([])
    end
  end

  describe '#switch_player' do
    it 'switches from white to black' do
      game.switch_player
      expect(game.current_player).to eq(:black)
    end

    it 'switches from black to white' do
      game.switch_player
      game.switch_player
      expect(game.current_player).to eq(:white)
    end
  end

  describe '#incheck?' do
    it 'delegates to board' do
      expect(game.board).to receive(:incheck?).with(:white).and_return(false)
      game.incheck?(:white)
    end

    it 'returns false in initial position' do
      expect(game.incheck?(:white)).to be false
    end
  end

  describe '#checkmate?' do
    it 'delegates to board' do
      expect(game.board).to receive(:incheckmate?).with(:black).and_return(false)
      game.checkmate?(:black)
    end
  end

  describe '#stalemate?' do
    it 'delegates to board' do
      expect(game.board).to receive(:stalemate?).with(:white).and_return(false)
      game.stalemate?(:white)
    end
  end

  describe '#parse_move' do
    it 'parses a simple pawn move' do
      move = game.parse_move('e2e4')
      expect(move.from).to eq([1, 4])
      expect(move.to).to eq([3, 4])
      expect(move.castle).to be_nil
    end

    it 'parses kingside castling (0-0)' do
      move = game.parse_move('0-0')
      expect(move.castle).to eq(:short)
    end

    it 'parses kingside castling (O-O)' do
      move = game.parse_move('O-O')
      expect(move.castle).to eq(:short)
    end

    it 'parses queenside castling (0-0-0)' do
      move = game.parse_move('0-0-0')
      expect(move.castle).to eq(:long)
    end

    it 'parses queenside castling (O-O-O)' do
      move = game.parse_move('O-O-O')
      expect(move.castle).to eq(:long)
    end

    it 'parses promotion' do
      move = game.parse_move('e7e8q')
      expect(move.from).to eq([6, 4])
      expect(move.to).to eq([7, 4])
      expect(move.promotion).to eq(:queen)
    end

    it 'parses promotion with equals sign' do
      move = game.parse_move('e7e8=Q')
      expect(move.promotion).to eq(:queen)
    end

    it 'raises error for invalid format' do
      expect { game.parse_move('invalid') }.to raise_error(ArgumentError)
    end

    it 'raises error for out-of-board coordinates' do
      expect { game.parse_move('i9i9') }.to raise_error(ArgumentError)
    end

    it 'strips whitespace' do
      move = game.parse_move('  e2e4  ')
      expect(move.from).to eq([1, 4])
    end
  end

  describe '#make_move' do
    it 'applies a legal move and switches player' do
      result = game.make_move('e2e4')
      expect(result).to be true
      expect(game.current_player).to eq(:black)
    end

    it 'rejects an illegal move' do
      result = game.make_move('e2e5')
      expect(result).to be false
      expect(game.current_player).to eq(:white)
    end

    it 'records move in history' do
      game.make_move('e2e4')
      history = game.instance_variable_get(:@history)
      expect(history.size).to eq(1)
      expect(history[0]).to be_a(Move)
    end

    it 'stores move with from, to, piece in history' do
      game.make_move('e2e4')
      move = game.instance_variable_get(:@history).last
      expect(move.from).to eq([1, 4])
      expect(move.to).to eq([3, 4])
      expect(move.piece).to be_a(Pawn)
      expect(move.piece.color).to eq(:white)
    end

    it 'stores move with capture nil for non-capture' do
      game.make_move('e2e4')
      move = game.instance_variable_get(:@history).last
      expect(move.capture).to be_nil
    end

    it 'stores move with capture set on capture' do
      game.make_move('e2e4')
      game.make_move('d7d5')
      game.make_move('e4d5')
      move = game.instance_variable_get(:@history).last
      expect(move.capture).to be_a(Pawn)
      expect(move.capture.color).to eq(:black)
    end

    it 'stores move with check flag when delivering check' do
      game.make_move('e2e4')
      game.make_move('f7f6')
      game.make_move('d1h5')
      move = game.instance_variable_get(:@history).last
      expect(move.check).to be true
    end

    it 'stores move with checkmate flag when checkmate' do
      game.make_move('e2e4')
      game.make_move('e7e5')
      game.make_move('f1c4')
      game.make_move('b8c6')
      game.make_move('d1h5')
      game.make_move('g8f6')
      game.make_move('h5f7')
      move = game.instance_variable_get(:@history).last
      expect(move.checkmate).to be true
    end

    it 'stores castling move with castle field set' do
      b = game.board
      (0..7).each { |r| (0..7).each { |c| b.set_piece([r, c], nil) } }
      b.set_piece([0, 4], King.new(:white, [0, 4]))
      b.set_piece([0, 7], Rook.new(:white, [0, 7]))
      b.set_piece([7, 4], King.new(:black, [7, 4]))
      game.make_move('0-0')
      move = game.instance_variable_get(:@history).last
      expect(move.castle).to eq(:short)
      expect(move.from).to be_nil
      expect(move.to).to be_nil
      expect(move.piece).to be_nil
    end

    it 'stores promotion move with promotion field set' do
      b = game.board
      (0..7).each { |r| (0..7).each { |c| b.set_piece([r, c], nil) } }
      b.set_piece([0, 4], King.new(:white, [0, 4]))
      b.set_piece([7, 4], King.new(:black, [7, 4]))
      b.set_piece([6, 0], Pawn.new(:white, [6, 0]))
      game.make_move('a7a8q')
      move = game.instance_variable_get(:@history).last
      expect(move.promotion).to eq(:queen)
    end

    it 'handles castling' do
      game.instance_variable_set(:@board, Board.new)
      b = game.board
      (0..7).each { |r| (0..7).each { |c| b.set_piece([r, c], nil) } }
      b.set_piece([0, 4], King.new(:white, [0, 4]))
      b.set_piece([0, 7], Rook.new(:white, [0, 7]))
      b.set_piece([7, 4], King.new(:black, [7, 4]))
      result = game.make_move('0-0')
      expect(result).to be true
      expect(b.piece_at([0, 6])).to be_a(King)
    end
  end

  describe '#undo' do
    it 'undoes the last move' do
      from_piece = game.board.piece_at([1, 0])
      game.make_move('a2a3')
      game.undo
      expect(game.board.piece_at([1, 0])).to eq(from_piece)
      expect(game.board.piece_at([2, 0])).to be_nil
      expect(game.current_player).to eq(:white)
    end

    it 'does nothing when history is empty' do
      expect { game.undo }.not_to change { game.current_player }
    end

    it 'resets has_moved? for a King that moved' do
      game.make_move('e2e4')
      game.make_move('e7e5')
      game.make_move('e1e2')
      expect(game.board.piece_at([1, 4]).has_moved?).to be true
      game.undo
      expect(game.board.piece_at([0, 4]).has_moved?).to be false
    end

    it 'resets has_moved? for a Rook that moved' do
      game.make_move('a2a4')
      game.make_move('a7a5')
      game.make_move('a1a3')
      expect(game.board.piece_at([2, 0]).has_moved?).to be true
      game.undo
      expect(game.board.piece_at([0, 0]).has_moved?).to be false
    end

    it 'restores a captured piece' do
      game.make_move('e2e4')
      game.make_move('d7d5')
      game.make_move('e4d5')
      expect(game.board.piece_at([4, 3]).color).to eq(:white)
      game.undo
      expect(game.board.piece_at([3, 4])).to be_a(Pawn)
      expect(game.board.piece_at([3, 4]).color).to eq(:white)
      expect(game.board.piece_at([4, 3])).to be_a(Pawn)
      expect(game.board.piece_at([4, 3]).color).to eq(:black)
    end

    it 'restores kingside castling positions and resets has_moved?' do
      b = game.board
      (0..7).each { |r| (0..7).each { |c| b.set_piece([r, c], nil) } }
      b.set_piece([0, 4], King.new(:white, [0, 4]))
      b.set_piece([0, 7], Rook.new(:white, [0, 7]))
      b.set_piece([7, 4], King.new(:black, [7, 4]))
      game.make_move('0-0')
      game.undo
      expect(b.piece_at([0, 4])).to be_a(King)
      expect(b.piece_at([0, 7])).to be_a(Rook)
      expect(b.piece_at([0, 5])).to be_nil
      expect(b.piece_at([0, 6])).to be_nil
      expect(b.piece_at([0, 4]).has_moved?).to be false
      expect(b.piece_at([0, 7]).has_moved?).to be false
    end

    it 'restores queenside castling positions and resets has_moved?' do
      b = game.board
      (0..7).each { |r| (0..7).each { |c| b.set_piece([r, c], nil) } }
      b.set_piece([0, 4], King.new(:white, [0, 4]))
      b.set_piece([0, 0], Rook.new(:white, [0, 0]))
      b.set_piece([7, 4], King.new(:black, [7, 4]))
      game.make_move('0-0-0')
      game.undo
      expect(b.piece_at([0, 4])).to be_a(King)
      expect(b.piece_at([0, 0])).to be_a(Rook)
      expect(b.piece_at([0, 2])).to be_nil
      expect(b.piece_at([0, 3])).to be_nil
      expect(b.piece_at([0, 4]).has_moved?).to be false
      expect(b.piece_at([0, 0]).has_moved?).to be false
    end

    it 'restores black kingside castling' do
      b = game.board
      (0..7).each { |r| (0..7).each { |c| b.set_piece([r, c], nil) } }
      b.set_piece([0, 4], King.new(:white, [0, 4]))
      b.set_piece([7, 4], King.new(:black, [7, 4]))
      b.set_piece([7, 7], Rook.new(:black, [7, 7]))
      game.switch_player
      game.make_move('0-0')
      game.undo
      expect(b.piece_at([7, 4])).to be_a(King)
      expect(b.piece_at([7, 7])).to be_a(Rook)
      expect(b.piece_at([7, 4]).has_moved?).to be false
      expect(b.piece_at([7, 7]).has_moved?).to be false
    end

    it 'restores promotion (pawn reverts to pawn)' do
      b = game.board
      (0..7).each { |r| (0..7).each { |c| b.set_piece([r, c], nil) } }
      b.set_piece([0, 4], King.new(:white, [0, 4]))
      b.set_piece([7, 4], King.new(:black, [7, 4]))
      b.set_piece([6, 0], Pawn.new(:white, [6, 0]))
      game.make_move('a7a8q')
      expect(b.piece_at([7, 0])).to be_a(Queen)
      game.undo
      expect(b.piece_at([7, 0])).to be_nil
      expect(b.piece_at([6, 0])).to be_a(Pawn)
    end

    it 'can undo all moves back to initial position' do
      moves = %w[e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d1e2 f8e7]
      moves.each { |m| game.make_move(m) }
      expect(game.current_player).to eq(:white)
      expect(game.instance_variable_get(:@history).size).to eq(8)
      8.times { game.undo }
      expect(game.current_player).to eq(:white)
      expect(game.instance_variable_get(:@history)).to be_empty
      expect(game.board.piece_at([1, 4])).to be_a(Pawn)
      expect(game.board.piece_at([0, 4])).to be_a(King)
    end

    it 'restores en passant capture' do
      game.make_move('e2e4')
      game.make_move('a7a6')
      game.make_move('e4e5')
      game.make_move('d7d5')
      game.make_move('e5d6')
      expect(game.board.piece_at([5, 3])).to be_a(Pawn)
      expect(game.board.piece_at([4, 3])).to be_nil
      game.undo
      expect(game.board.piece_at([4, 4])).to be_a(Pawn)
      expect(game.board.piece_at([4, 4]).color).to eq(:white)
      expect(game.board.piece_at([4, 3])).to be_a(Pawn)
      expect(game.board.piece_at([4, 3]).color).to eq(:black)
      expect(game.board.piece_at([5, 3])).to be_nil
    end

    it 'switches player back after undo' do
      game.make_move('e2e4')
      expect(game.current_player).to eq(:black)
      game.undo
      expect(game.current_player).to eq(:white)
      game.make_move('e2e4')
      game.make_move('e7e5')
      expect(game.current_player).to eq(:white)
      2.times { game.undo }
      expect(game.current_player).to eq(:white)
    end
  end

  describe '#save and #load' do
    it 'saves and loads game state' do
      Dir.mkdir('saves') unless Dir.exist?('saves')
      game.make_move('e2e4')
      filename = "test_save_#{Time.now.to_i}"
      game.save(filename)
      loaded = GameState.load(filename)
      expect(loaded.current_player).to eq(:black)
      expect(loaded.board.piece_at([3, 4])).to be_a(Pawn)
      File.delete("saves/#{filename}.dump")
    end
  end
end
