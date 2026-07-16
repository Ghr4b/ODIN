require_relative "board"
def check_winner(board)
  grid = board.grid
  winning_combinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6]
  ]
  winning_combinations.each do |a, b, c|
    return grid[a] if grid[a] == grid[b] && grid[b] == grid[c]
  end
  nil
end
