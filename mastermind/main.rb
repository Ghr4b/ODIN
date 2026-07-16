require_relative 'lib/code'
try = 1
code = nil
loop do
  begin
    puts "Enter the secret code:"
    puts "format eg 'red blue green yellow'"
    secret = gets.chomp
    code = Code.new(secret.split(' '))
    break
  rescue ArgumentError => e
    puts "Invalid code, #{e.message}. Please enter a valid code."
  end

end
loop do
  begin
    puts "Enter your guess:"
    puts "format eg 'red blue green yellow'"

    guess = gets.chomp
    result = code.check_guess(guess.split(' '))
  rescue ArgumentError => e
    puts "Invalid guess, #{e.message}. Please enter a valid guess."
    next
  end
  if result == nil
    puts "Correct! You guessed the code in #{try} try."
    break
  end
  puts "you have #{result[0]} reds and #{result[1]} whites"
  try += 1
end
