class Code
  COLORS = %w[red blue green yellow purple orange]

  attr_reader :secret_code

  def initialize(secret_code)
    raise ArgumentError, "Invalid code: #{secret_code}" unless validate_code(secret_code)
    @secret_code = secret_code
  end

  def check_guess(guess)
    raise ArgumentError, "Invalid guess: #{guess}" unless validate_code(guess)

    exact_indices = []
    secret_code.each_with_index do |s, i|
      exact_indices << i if s == guess[i]
    end

    reds = exact_indices.count

    leftover_secret = secret_code.each_with_index.reject { |_, i| exact_indices.include?(i) }.map(&:first)
    leftover_guess  = guess.each_with_index.reject  { |_, i| exact_indices.include?(i) }.map(&:first)

    whites = 0
    leftover_guess.each do |color|
      whiteindex = leftover_secret.index(color)
      if whiteindex
        whites += 1
        leftover_secret.delete_at(whiteindex)
      end
    end

    [reds, whites]
  end

  private

  def validate_code(code)
    code_array = code.is_a?(String) ? code.chars : code

    if code_array.length != 4 or code_array.any? { |c| !COLORS.include?(c) }
      return false
    end

    true
  end
end
