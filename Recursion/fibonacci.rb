def fibs(n)
  result = []
  n.times do |i|
    if i < 2
      result << i
    else
      result << result[-1] + result[-2]
    end
  end
  result
end

def fib_rec(n)
  return [] if n < 1
  return [0] if n == 1
  return [0, 1] if n == 2
  arr = fib_rec(n - 1)
  arr << arr[-1] + arr[-2]
  arr
end
puts fib_rec(-1).inspect
puts fib_rec(1).inspect
puts fib_rec(2).inspect
puts fib_rec(8).inspect
puts fib_rec(4).inspect
