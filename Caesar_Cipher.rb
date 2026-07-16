def caesar_cipher(str, shift)
  result = str.split("").map do |char|
    case char
    when /[A-Z]/
      ((char.ord - 65 + shift) % 26 + 65).chr
    when /[a-z]/
      ((char.ord - 97 + shift) % 26 + 97).chr
    else
      char
    end
  end
  result.join("")
end
puts caesar_cipher("What a string!", 5)
