require_relative 'lib/Board'
require_relative 'lib/piece'
require_relative 'lib/moves'
require_relative 'lib/gamestate'

game = GameState.new

loop do
  system('clear') || system('cls')
  game.board.display

  color = game.current_player
  opponent = color == :white ? :black : :white

  if game.checkmate?(color)
    puts "#{color.capitalize} is in checkmate. #{opponent.capitalize} wins!"
    break
  elsif game.stalemate?(color)
    puts "Stalemate! The game is a draw."
    break
  elsif game.incheck?(color)
    puts "#{color.capitalize} is in check!"
  end

  print "#{color.capitalize}'s move (e.g. e2e4, 0-0, undo, save, quit): "
  input = $stdin.gets
  break unless input
  input = input.strip.downcase

  case input
  when 'quit', 'exit'
    puts "Game ended."
    break
  when 'undo'
    if game.instance_variable_get(:@history).empty?
      puts "No moves to undo."
    else
      game.undo
      puts "Move undone."
    end
  when 'save'
    game.save
    puts "Game saved."
  when 'load'
    if File.exist?("#{Time.now.to_i}.dump")
      game = GameState.load(Time.now.to_i.to_s)
      puts "Game loaded."
    else
      puts "No save file found."
    end
  else
    begin
      success = game.make_move(input)
      puts "Invalid move. Try again." unless success
    rescue ArgumentError => e
      puts "Error: #{e.message}"
    end
  end
end
