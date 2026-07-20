require_relative 'Board'
require_relative 'piece'
require_relative 'moves'
class GameState
  attr_accessor :current_player, :board

  def initialize
    @board = Board.new
    @players = [:white, :black]
    @current_player = @players[0]
    @history = [] # history in pgn
    @stalemate_count = 0
  end
  def switch_player
    @current_player = @players[1 - @players.index(@current_player)]
  end
  def incheck?(color)
    @board.incheck?(color)
  end
  def checkmate?(color)
    @board.incheckmate?(color)
  end
  def stalemate?(color)
    @board.stalemate?(color) or @stalemate_count >= 100
  end

  def parse_move(input)
    clean_input = input.to_s.strip

    # castling
    if clean_input.match?(/^(0-0-0|O-O-O)$/i)
      move = Move.new
      move.castle = :long
      return move
    elsif clean_input.match?(/^(0-0|O-O)$/i)
      move = Move.new
      move.castle = :short
      return move
    end

    # validation
    unless clean_input.match?(/^[a-h][1-8][a-h][1-8](=?[QRBN])?$/i)
      raise ArgumentError, "Invalid move format. Use Coordinate Notation ."
    end

    move = Move.new

    # promotion
    if clean_input.match(/([QRBN])$/i)
      move.promotion = $1.upcase.to_sym
      clean_input = clean_input.sub(/=?[QRBN]$/i, '')
    end

    move.from = @board.square_to_coord(clean_input[0..1])
    move.to = @board.square_to_coord(clean_input[2..3])

    move
  end
  def make_move(input)
    move = parse_move(input)
    success, move = apply_move(@board, move, @current_player, @history[-1])
    if success
      switch_player
      @history << move
    end
    @stalemate_count += 1 if success and !( move.capture || move.piece.is_a?(Pawn) )
    success
  end
  def undo()
    if @history.any?
      move = @history.pop
      @board.undo_move(move)
      switch_player
    end
  end
  def save(filename = Time.now.to_i)
    File.open("saves/#{filename}.dump", "wb") do |f|
      f.write(Marshal.dump(self))
    end
    filename
  end

  def self.load(filename)
    File.open("saves/#{filename}.dump", "rb") do |f|
      Marshal.load(f)
    end
  end
end
