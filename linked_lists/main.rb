require_relative 'linked_lists'

list = LinkedList.new

list.append('dog')
list.append('cat')
list.append('parrot')
list.append('hamster')
list.append('snake')
list.append('turtle')

puts list
list.insert_at('elephant', 3)
puts list
