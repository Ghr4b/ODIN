def substrings(str, dict)
  result = {}
  dict.each do |word|
    if str.include?(word)
      result[word] = str.gsub(word).count
    end
  end
  result
end
dictionary = ["below","down","go","going","horn","how","howdy","it","i","low","own","part","partner","sit"]
puts substrings("go below it now belows", dictionary)
