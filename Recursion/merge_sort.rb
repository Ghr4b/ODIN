def merge_sort(arr)
  puts 'This was printed recursively'

  if arr.length <= 1
    return arr
  end
  last = arr.pop
  sorted = merge_sort(arr)
  i = 0
  while  i < sorted.length and last > sorted[i]
    i += 1
  end
  sorted.insert(i, last)
end

puts merge_sort([3, 2, 1, 13, 8, 5, 0, 1, -5, 100]).inspect
