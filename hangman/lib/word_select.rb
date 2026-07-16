def select_word(wordlist="google-10000-english-no-swears.txt")
  if !File.exist?(wordlist)
    puts "No word list found. Please download the word list."
    exit
  end
  valid_words = File.readlines(wordlist).map(&:chomp).select do |word|
      word.length.between?(5, 12)
    end

    valid_words.sample
end
