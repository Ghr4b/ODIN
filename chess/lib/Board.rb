class Board
  SIZE = 8

  def initialize
    @squares = Array.new(64)
    setup_starting_position
  end

  def piece_at(pos)      = @squares[to_index(pos)]
  def set_piece(pos, pc) = @squares[to_index(pos)] = pc
  def empty?(pos)        = @squares[to_index(pos)].nil?
  def move(from, to)
    piece = piece_at(from)
    set_piece(to, piece)
    set_piece(from, nil)
  end
  # def in_bounds?(row, col) = row.between?(0,7) && col.between?(0,7)
  def find_king(color)
    @squares.each_with_index do |piece, index|
      return index if piece.is_a?(King) && piece.color == color
    end
    nil
  end
  def all_pieces(color)
    @squares.compact.select { |piece| piece.color == color }
  end

  private

  def to_index(pos)
    row, col = pos
    row * SIZE + col
  end
  def setup_starting_position()
    # setup pawns
    (0..7).each do |col|
      set_piece([1, col], Pawn.new(:white, [1, col]))
      set_piece([6, col], Pawn.new(:black, [6, col]))
    end
    # setup rooks
    set_piece([0, 0], Rook.new(:white, [0, 0]))
    set_piece([0, 7], Rook.new(:white, [0, 7]))
    set_piece([7, 0], Rook.new(:black, [7, 0]))
    set_piece([7, 7], Rook.new(:black, [7, 7]))
    # setup knights
    set_piece([0, 1], Knight.new(:white, [0, 1]))
    set_piece([0, 6], Knight.new(:white, [0, 6]))
    set_piece([7, 1], Knight.new(:black, [7, 1]))
    set_piece([7, 6], Knight.new(:black, [7, 6]))
    # setup bishops
    set_piece([0, 2], Bishop.new(:white, [0, 2]))
    set_piece([0, 5], Bishop.new(:white, [0, 5]))
    set_piece([7, 2], Bishop.new(:black, [7, 2]))
    set_piece([7, 5], Bishop.new(:black, [7, 5]))
    # setup queens
    set_piece([0, 3], Queen.new(:white, [0, 3]))
    set_piece([7, 3], Queen.new(:black, [7, 3]))
    # setup kings
    set_piece([0, 4], King.new(:white, [0, 4]))
    set_piece([7, 4], King.new(:black, [7, 4]))

  end
end
