require_relative 'board'
require_relative 'piece'
require_relative 'moves'
class GameState
  attr_accessor :current_player, :board

  def initialize
    @board = Board.new
    @players = [:white, :black]
    @current_player = @players[0]
  end
  def switch_player
    @current_player = @players[1 - @players.index(@current_player)]
  end
  def incheck?(color)
    all_pieces = board.all_pieces(color)
    result = all_pieces.any? { |piece| piece.pseudo_legal_moves(board).any? { |pos| board.piece_at(pos).is_a?(King) and board.piece_at(pos).color != color } }
    result
  end
  def incheckmate?(color)
    incheck?(color) && legal_moves_color(board, color).empty?
  end
end
