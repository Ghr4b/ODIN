require_relative 'Board'
require_relative 'pieces'
Move = Struct.new(:from, :to, :piece, :capture?, :castle, :promotion)


def incheckafter?(board, color, move = nil)
  if move
    board.move(move.from, move.to)
  end
  all_pieces = board.all_pieces(color)
  result = all_pieces.any? { |piece| piece.pseudo_legal_moves(board).any? { |pos| board.piece_at(pos).is_a?(King) and board.piece_at(pos).color != color } }
  if move
    board.move(move.to, move.from)
  end
  result
end
def legal_moves(board, piece)
  piece.pseudo_legal_moves(board).select { |pos| incheckafter?(board, piece.color, Move.new(from: piece.position, to: pos)) }
end
def can_castle(board, color, side)
  if side != :long || side != :short
    return false
  end
  king_pos = color == :white ? [0, 4] : [7, 4]
  if piece_at(board, king_pos).is_a?(King)
    king = piece_at(board, king_pos)
    num_moves = side == :long ? 3 : 2
    king_destination = case [side, color]
      when [:long, :white] then [0, 2]
      when [:long, :black] then [7, 2]
      when [:short, :white] then [0, 6]
      when [:short, :black] then [7, 6]
    end
    if king.has_moved
      return false
    end
    if piece_at(board, king_destination).is_a?(Rook)
      rook = piece_at(board, king_destination)
      if rook.has_moved
        return false
      end
      if [king_pos[0], king_destination[0]].all? { |i| board.empty?([king_pos[0], i]) && !incheckafter?(board, color, Move.new(from: king_pos, to: [king_pos[0], i])) }
        return true
      end
    end
  end
  return false
end
def legal_moves_color(board, color)
  all_pieces = board.all_pieces(color)
  all_pieces.flat_map { |piece| legal_moves(board, piece) }
end
def apply_move(board, move, color)
  if move.castle and can_castle(board, color, move.castle)
    king_pos = color == :white ? [0, 4] : [7, 4]
    king_destination = move.castle == :long ? [0, 2] : [7, 6]
    rook_pos = color == :white ? [0, 7] : [7, 7]
    rook_destination = move.castle == :long ? [0, 3] : [7, 5]
    board.move(king_pos, king_destination)
    board.move(rook_pos, rook_destination)
  end
  piece = board.piece_at(move.from)
  if piece && legal_moves(board, piece).include?(move.to)
    board.move(move.from, move.to)
  end
end
