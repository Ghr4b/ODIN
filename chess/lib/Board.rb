require_relative 'piece'

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
    capture = nil
    piece = piece_at(from)
    return unless piece
    if piece.enemy?(piece_at(to))
      capture = piece_at(to)
    end
    piece.position = to
    if piece.is_a?(King) || piece.is_a?(Rook)
      piece.has_moved = true
    end
    set_piece(to, piece)
    set_piece(from, nil)
    capture
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
  def display
    bg_light = "\e[48;5;250m\e[30m"
    bg_dark  = "\e[48;5;238m\e[37m"
    reset    = "\e[0m"

    puts "   a b c d e f g h"

    @squares.each_slice(8).with_index do |row, row_idx|
      row_num = 8 - row_idx

      formatted_row = row.map.with_index do |piece, col_idx|
        bg = (row_idx + col_idx).even? ? bg_light : bg_dark
        symbol = piece ? piece.to_s : " "

        "#{bg} #{symbol} #{reset}"
      end.join

      puts "#{row_num} #{formatted_row} #{row_num}"
    end

    puts "   a b c d e f g h"
  end
  def incheck?(color)
    opponent = color == :white ? :black : :white
    all_pieces = all_pieces(opponent)
    result = all_pieces.any? { |piece| piece.pseudo_legal_moves(self).any? { |pos| piece_at(pos).is_a?(King) and piece_at(pos).color == color } }
    result
  end
  def incheckmate?(color)
    incheck?(color) && legal_moves_color(self, color).empty?
  end
  def stalemate?(color)
    legal_moves_color(self, color).empty? && !incheck?(color)
  end
  def handle_promotion(pos, promotion, color)
    case promotion
    when :queen
      set_piece(pos, Queen.new(color, pos))
    when :rook
      set_piece(pos, Rook.new(color, pos))
    when :bishop
      set_piece(pos, Bishop.new(color, pos))
    when :knight
      set_piece(pos, Knight.new(color, pos))
    end
  end
  def square_to_coord(square)
    return nil unless square.match?(/^[a-h][1-8]$/i)

    col = square.downcase[0].ord - 'a'.ord
    row = square[1].to_i - 1

    [row, col]
  end
  def undo_move(move)
    set_piece(move.from, move.piece)
    set_piece(move.to, move.capture)
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
