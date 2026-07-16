require_relative 'word_select'
class Hangman
  attr_reader :guessed
  attr_reader :word
  attr_reader :tries
  def initialize()
    @word = select_word("google-10000-english-no-swears.txt")
    @guessed = "-" * @word.length
    @tries = 18
  end

  def guess(letter)
    if letter.length != 1
      raise ArgumentError, "guess must be a single character"
    end
    if !letter.match?(/[a-zA-Z]/)
      raise ArgumentError, "guess must be a letter"
    end

    @word.chars.each_with_index do |char, index|
      if char == letter
        @guessed[index] = letter
      end
    end
    @tries -= 1
    @guessed
  end
  def won?
    @guessed.include?("-") == false
  end
  def guess_word(guess)
    if guess != @word
      @tries -= 1
    else
      @guessed = @word
    end
    won?
  end
  def save
    if !Dir.exist?("save")
      Dir.mkdir("save")
    end
    filename = Time.now.to_i
    File.open("save/#{filename}.dat", "wb") do |f|
      f.write(Marshal.dump(self))
    end
    puts "saved to save/#{filename}.dat"
  end
  def self.load(filename)
    if !File.exist?("save/#{filename}.dat")
      raise ArgumentError, "file not found"
      return nil
    end
    saved_data = File.binread("save/#{filename}.dat")
    puts "game loaded successfully"
    return Marshal.load(saved_data)
  end
end
