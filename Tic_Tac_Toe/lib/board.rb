class Board
  attr_reader :grid
  def initialize
    @grid = (1..9).map(&:to_s)
  end

  def display
    puts " #{@grid[0]} | #{@grid[1]} | #{@grid[2]} "
    puts "-----------"
    puts " #{@grid[3]} | #{@grid[4]} | #{@grid[5]} "
    puts "-----------"
    puts " #{@grid[6]} | #{@grid[7]} | #{@grid[8]} "
  end

  def update(index, player)
    raise "Invalid player" if player != "X" && player != "O"
    raise "Invalid index" if index < 0 || index >= 9
    raise "Cell already occupied" if @grid[index].match?(/[XO]/)

    @grid[index] = player
  end
end
