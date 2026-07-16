class Code
  COLORS = %w[red orange yellow green blue purple]
  attr_reader :secret
  def initialize(secret)
    raise ArgumentError, "Invalid code: #{secret}" unless validate_code(secret)
    @secret = secret
  end

  def check_guess(guess)
    raise ArgumentError, "Invalid guess: #{guess}" unless validate_code(guess)
    exact_matches = secret.zip(guess).select { |s, g| s == g } .map(&:first)
    reds = exact_matches.count
    whites = (guess - exact_matches).count { |c| (secret - exact_matches).include?(c) }
    [reds, whites]
  end
end
def validate_code(code)
  if code.length != 4 or code.chars.any? { |c| !Code::COLORS.include?(c) }
    return false
  end
  return true
end
