class Board
  attr_reader :grid

  ROWS = 6
  COLS = 7

  def initialize
    @grid = Array.new(ROWS) { Array.new(COLS, nil) }
  end

  def drop(col, piece)
    return false if col < 0 || col >= COLS || column_full?(col)

    row = lowest_empty_row(col)
    @grid[row][col] = piece
    true
  end

  def column_full?(col)
    return true if col < 0 || col >= COLS
    @grid[0][col] != nil
  end

  def full?
    @grid.all? { |row| row.all? { |cell| cell != nil } }
  end

  def win?(piece)
    horizontal_win?(piece) || vertical_win?(piece) || diagonal_win?(piece)
  end

  def winner
    [:X, :O].each { |piece| return piece if win?(piece) }
    nil
  end

  def display
    puts " 1 2 3 4 5 6 7"
    @grid.each do |row|
      print "|"
      row.each do |cell|
        print "#{cell || " "}|"
      end
      puts
    end
    puts "---------------"
  end

  private

  def lowest_empty_row(col)
    (ROWS - 1).downto(0) do |row|
      return row if @grid[row][col].nil?
    end
  end

  def horizontal_win?(piece)
    @grid.any? do |row|
      row.each_cons(4).any? { |cons| cons.all? { |cell| cell == piece } }
    end
  end

  def vertical_win?(piece)
    (0...COLS).any? do |col|
      (0..ROWS - 4).any? do |row|
        (0..3).all? { |offset| @grid[row + offset][col] == piece }
      end
    end
  end

  def diagonal_win?(piece)
    (0..ROWS - 4).any? do |row|
      (0..COLS - 4).any? do |col|
        (0..3).all? { |offset| @grid[row + offset][col + offset] == piece }
      end
    end ||
    (0..ROWS - 4).any? do |row|
      (3...COLS).any? do |col|
        (0..3).all? { |offset| @grid[row + offset][col - offset] == piece }
      end
    end
  end
end
