class Piece
  attr_accessor :color, :position

  def initialize(color, position)
    @color = color
    @position = position
  end

  def symbol
    raise NotImplementedError, "#{self.class} must implement #symbol"
  end

  def pseudo_legal_moves(board)
    raise NotImplementedError, "#{self.class} must implement #pseudo_legal_moves"
  end

  def enemy?(other_piece)
    !other_piece.nil? && other_piece.color != color
  end

  def friendly?(other_piece)
    !other_piece.nil? && other_piece.color == color
  end

  private

  def on_board?(row, col)
    row.between?(0, 7) && col.between?(0, 7)
  end
end


class Pawn < Piece
  def symbol
    color == :white ? '♙' : '♟'
  end
  def possible_moves(board)
    moves = []
    row, col = position
    direction = color == :white ? 1 : -1
    start_rank = color == :white ? 1 : 6
    # one step forward
    if on_board?(row + direction, col) && board.piece_at([row + direction, col]) == nil
      moves << [row + direction, col]
    end
    # two steps forward
    if row == start_rank && board.piece_at([row + direction, col]) == nil && board.piece_at([row + 2 * direction, col]) == nil
      moves << [row + 2 * direction, col]
    end
    # capture
    if on_board?(row + direction, col + 1) && enemy?(board.piece_at([row + direction, col + 1]))
      moves << [row + direction, col + 1]
    end
    if on_board?(row + direction, col - 1) && enemy?(board.piece_at([row + direction, col - 1]))
      moves << [row + direction, col - 1]
    end
    moves
  end
end

class King < Piece
  DIRECTIONS = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1],           [0, 1],
    [1, -1],  [1, 0],  [1, 1]
  ].freeze

  attr_accessor :has_moved

  def initialize(color, position)
    super
    @has_moved = false
  end

  def symbol
    color == :white ? '♔' : '♚'
  end

  def pseudo_legal_moves(board)
    row, col = position

    moves = []
    DIRECTIONS.each do |d_row, d_col|
      r, c = row + d_row, col + d_col
      moves << [r, c] if on_board?(r, c) and ( board.piece_at([r, c]) == nil or enemy?(board.piece_at([r, c])))
    end
    moves
  end
end


module SlidingPiece
  def slide_moves(board, directions)
    moves = []
    row, col = position

    directions.each do |d_row, d_col|
      r, c = row + d_row, col + d_col

      while on_board?(r, c)
        target = board.piece_at([r, c])
        if target.nil?
          moves << [r, c]
        # capture
        elsif enemy?(target)
          moves << [r, c]
          break
        # blocked
        else
          break
        end

        r += d_row
        c += d_col
      end
    end

    moves
  end
end


  def on_starting_rank?
    start_rank = color == :white ? 6 : 1
    position[0] == start_rank
  end
end

class Knight < Piece
  KNIGHT_OFFSETS = [
    [-2, -1], [-2, 1], [-1, -2], [-1, 2],
    [1, -2],  [1, 2],  [2, -1],  [2, 1]
  ].freeze

  def symbol
    color == :white ? '♘' : '♞'
  end

  def pseudo_legal_moves(board)
    row, col = position

    moves = []
    KNIGHT_OFFSETS.each do |d_row, d_col|
      r, c = row + d_row, col + d_col
      moves << [r, c] if on_board?(r, c) and (board.piece_at([r, c]) == nil or enemy?(board.piece_at([r, c])))
    end
    moves
  end
end

class Bishop < Piece
  include SlidingPiece

  DIRECTIONS = [[-1, -1], [-1, 1], [1, -1], [1, 1]].freeze

  def symbol
    color == :white ? '♗' : '♝'
  end

  def pseudo_legal_moves(board)
    slide_moves(board, DIRECTIONS)
  end
end

class Rook < Piece
  include SlidingPiece

  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1]].freeze

  attr_accessor :has_moved

  def initialize(color, position)
    super
    @has_moved = false
  end

  def symbol
    color == :white ? '♖' : '♜'
  end

  def pseudo_legal_moves(board)
    slide_moves(board, DIRECTIONS)
  end
end

class Queen < Piece
  include SlidingPiece

  DIRECTIONS = [
    [-1, -1], [-1, 1], [1, -1], [1, 1],
    [-1, 0],  [1, 0],  [0, -1], [0, 1]
  ].freeze

  def symbol
    color == :white ? '♕' : '♛'
  end

  def pseudo_legal_moves(board)
    slide_moves(board, DIRECTIONS)
  end
end
