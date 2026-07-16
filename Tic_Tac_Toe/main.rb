require_relative "lib/status"
require_relative "lib/board"

board = Board.new
players = ["X", "O"]
player_cycle = players.cycle
winner = nil
loop do
  current_player = player_cycle.next
  board.display
  puts "turn for player #{current_player}"
  puts "Enter a position (1-9):"

  begin
    position = gets.chomp.to_i
    board.update(position - 1, current_player)
  rescue RuntimeError => e
    puts "Error: #{e.message}, please try again."
    retry
  end
  winner = check_winner(board)
  break if winner or board.full?
  puts "No winner yet. Next turn."
end
puts "Game over!"
puts winner ? "The winner is #{winner}!" : "It's a draw!"

board.display
