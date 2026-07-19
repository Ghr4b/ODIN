require_relative 'node'
require_relative 'tree'

arr = Array.new(15) { rand(1..100) }
tree = Tree.new(arr)

puts "Initial tree:"
puts "Balanced? #{tree.balanced?}"

puts "\nLevel order:"
tree.level_order { |d| print "#{d} " }
puts "\nPreorder:"
tree.preorder { |d| print "#{d} " }
puts "\nPostorder:"
tree.postorder { |d| print "#{d} " }
puts "\nInorder:"
tree.inorder { |d| print "#{d} " }

puts "\n\nAdding numbers > 100 to unbalance..."
[101, 105, 110, 120, 130, 150, 200, 250, 300].each { |n| tree.insert(n) }

puts "Balanced? #{tree.balanced?}"

puts "\nRebalancing..."
tree.rebalance

puts "Balanced? #{tree.balanced?}"

puts "\nLevel order:"
tree.level_order { |d| print "#{d} " }
puts "\nPreorder:"
tree.preorder { |d| print "#{d} " }
puts "\nPostorder:"
tree.postorder { |d| print "#{d} " }
puts "\nInorder:"
tree.inorder { |d| print "#{d} " }
puts
