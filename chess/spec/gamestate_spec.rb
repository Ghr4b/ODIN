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
      expect(move.promotion).to eq(:Q)
    end

    it 'parses promotion with equals sign' do
      move = game.parse_move('e7e8=Q')
      expect(move.promotion).to eq(:Q)
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
