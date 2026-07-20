require_relative 'Board'
require_relative 'piece'
Move = Struct.new(:from, :to, :piece, :capture, :castle, :promotion, :checkmate, :check)


def incheckafter?(board, color, move = nil)
  if move
    captured_piece = board.move(move.from, move.to)
  end
  opponent = color == :white ? :black : :white
  all_pieces = board.all_pieces(opponent)
  result = all_pieces.any? { |piece| piece.pseudo_legal_moves(board).any? { |pos| board.piece_at(pos).is_a?(King) and board.piece_at(pos).color == color } }
  if move
    board.move(move.to, move.from)
    board.set_piece(move.to, captured_piece)
  end
  result
end
def legal_moves(board, piece)
  piece.pseudo_legal_moves(board).reject { |pos| incheckafter?(board, piece.color, Move.new(from: piece.position, to: pos)) }
end
def can_castle(board, color, side)
  return false unless [:long, :short].include?(side)

  rank = color == :white ? 0 : 7
  king_pos = [rank, 4]

  king = board.piece_at(king_pos)
  return false unless king.is_a?(King) && !king.has_moved

  rook_col = side == :long ? 0 : 7
  rook_pos = [rank, rook_col]

  rook = board.piece_at(rook_pos)
  return false unless rook.is_a?(Rook) && !rook.has_moved

  empty_cols = side == :long ? [1, 2, 3] : [5, 6]
  return false unless empty_cols.all? { |col| board.piece_at([rank, col]).nil? }

  return false if incheckafter?(board, color)

  safe_cols = side == :long ? [3, 2] : [5, 6]
  safe_cols.all? do |col|
    move = Move.new
    move.from = king_pos
    move.to = [rank, col]
    !incheckafter?(board, color, move)
  end
end
def legal_moves_color(board, color)
  all_pieces = board.all_pieces(color)
  all_pieces.flat_map { |piece| legal_moves(board, piece) }
end
def apply_move(board, move, color, last_move = nil)
  if move.castle
    return false unless can_castle(board, color, move.castle)
    castle(board, color, move.castle)
  else
    piece = board.piece_at(move.from)
    return false unless piece && piece.color == color
    move.piece = piece

    is_enPassant = handle_enpassant(board, move, last_move, piece)

    unless is_enPassant
      return false unless legal_moves(board, piece).include?(move.to)

      capture = board.move(move.from, move.to)
      move.capture = capture

      if piece.is_a?(Pawn) && (move.to[0] == 0 || move.to[0] == 7)
        board.handle_promotion(move.to, move.promotion, color)
      end
    end
  end

  opponent = (color == :white ? :black : :white)
  move.check = board.incheck?(opponent)
  move.checkmate = board.incheckmate?(opponent)

  [true, move]
end
def castle(board, color, side)
  row = color == :white ? 0 : 7
  is_long = side == :long
  king_start = [row, 4]
  king_dest  = [row, is_long ? 2 : 6]
  rook_start = [row, is_long ? 0 : 7]
  rook_dest  = [row, is_long ? 3 : 5]
  board.move(king_start, king_dest)
  board.move(rook_start, rook_dest)
  rook = board.piece_at(rook_dest)
  rook.has_moved = true
  king = board.piece_at(king_dest)
  king.has_moved = true
end
def handle_enpassant(board, move, last_move, piece)
  return false unless piece.is_a?(Pawn)
  return false unless last_move && last_move.piece.is_a?(Pawn)
  return false unless (last_move.from[0] - last_move.to[0]).abs == 2
  return false unless move.from[0] == last_move.to[0] && (move.from[1] - last_move.to[1]).abs == 1

  pass_through_square = [(last_move.from[0] + last_move.to[0]) / 2, last_move.to[1]]
  return false unless move.to == pass_through_square

  captured_pawn = last_move.piece
  board.set_piece(move.from, nil)
  board.set_piece(move.to, piece)
  board.set_piece(last_move.to, nil)

  if board.incheck?(piece.color)
    board.set_piece(move.from, piece)
    board.set_piece(move.to, nil)
    board.set_piece(last_move.to, captured_pawn)
    return false
  end
  piece.position = move.to
  move.capture = captured_pawn
  true
end
