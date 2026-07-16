require_relative "lib/status"
require_relative "lib/board"

board = Board.new
players = ["X", "O"]
player_cycle = players.cycle

loop do
  current_player = player_cycle.next
  board.display
  puts "turn for player #{current_player}"
  puts "Enter a position (1-9):"
  position = gets.chomp.to_i
  board.update(position - 1, current_player)
  winner = check_winner(board)
  if winner
    puts "Game over!"
    puts "The winner is #{winner}!"
    board.display
    break
  else
    puts "No winner yet. Next turn."
  end
end
