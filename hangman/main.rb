require_relative "lib/hangman"
require "json"
require "date"
puts "Welcome to Hangman!"
puts " enter n to start a new game, l to load a saved game"
case gets.chomp
when "n"
  game = Hangman.new
when "l"
  begin
    puts "the saved games are:"
    Dir["save/*"].each do |file|
      puts File.basename(file)
    end
    puts "enter the filename of the saved game: "
    filename = gets.chomp
    game = Hangman.load(filename)
  rescue ArgumentError => e
    puts "invalid filename, #{e.message}"
    return
  end
else
  puts "invalid input"
  return
end

while game.tries > 0 do
  begin
    puts "you have #{game.tries} tries left"
    puts "enter g to guess a letter, w to guess the word, s to save and quit"
    case gets.chomp
    when "g"
      puts "enter your guess: "
      guess = gets.chomp
      game.guess(guess)
      if game.won?
        puts "You win!"
        break
      end
      puts game.guessed
    when "w"
      puts "enter your guess: "
      guess = gets.chomp
      if game.guess_word(guess)
        puts "You win!"
        break
      else
        puts "incorrect guess"
        game.tries -= 1
      end
    when "s"
      puts "saving game..."
      game.save
      return

    end
  rescue ArgumentError => e
    puts e.message
    next

  end
end
if !game.won?
  puts "You lose!, the word was #{game.word}"
end
