require_relative 'lib/Board'
require_relative 'lib/piece'
require_relative 'lib/moves'
require_relative 'lib/gamestate'

Dir.mkdir('saves') unless Dir.exist?('saves')

game = GameState.new
message = nil

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

  puts message if message
  message = nil

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
      message = "No moves to undo."
    else
      game.undo
      puts "Move undone."
      $stdin.gets
    end
  when /^save(?:\s+(.+))?$/
    name = $1 ? game.save($1) : game.save
    puts "Saved successfully to #{name}.dump."
    $stdin.gets
  when /^load(?:\s+(.+))?$/
    name = $1
    if !name
      message = "Usage: load <filename>"
    elsif File.exist?("saves/#{name}.dump")
      game = GameState.load(name)
      puts "Game loaded from #{name}.dump."
      $stdin.gets
    else
      message = "No save file '#{name}.dump' found."
    end
  else
    begin
      success = game.make_move(input)
      message = "Invalid move. Try again." unless success
    rescue ArgumentError => e
      message = "Error: #{e.message}"
    end
  end
end
