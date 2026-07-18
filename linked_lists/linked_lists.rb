class Node
  attr_accessor :value, :next_node

  def initialize(value = nil)
    @value = value
    @next_node = nil
  end
end

class LinkedList
  def initialize
    @head = nil
    @tail = nil
  end

  def append(value)
    node = Node.new(value)
    if @head.nil?
      @head = node
      @tail = node
    else
      @tail.next_node = node
      @tail = node
    end
  end

  def prepend(value)
    node = Node.new(value)
    if @head.nil?
      @head = node
      @tail = node
    else
      node.next_node = @head
      @head = node
    end
  end

  def size
    count = 0
    current = @head
    while current
      count += 1
      current = current.next_node
    end
    count
  end

  def head
    @head&.value
  end

  def tail
    @tail&.value
  end

  def at(index)
    current = @head
    count = 0
    while current
      return current.value if count == index
      count += 1
      current = current.next_node
    end
    nil
  end

  def pop
    return nil if @head.nil?

    removed_value = @head.value
    @head = @head.next_node
    @tail = nil if @head.nil?
    removed_value
  end

  def contains?(value)
    current = @head
    while current
      return true if current.value == value
      current = current.next_node
    end
    false
  end

  def index(value)
    current = @head
    count = 0
    while current
      return count if current.value == value
      count += 1
      current = current.next_node
    end
    nil
  end

  def to_s
    return "" if @head.nil?

    current = @head
    str = ""
    while current
      str += "( #{current.value} ) -> "
      current = current.next_node
    end
    str += "nil"
    str
  end

  def insert_at(value, index)
   return nil if index < 0 || index > size
   if index == 0
     prepend(value)
   elsif index == size
     append(value)
   else
     current = @head
     count = 0
     while current
       if count == index - 1
         node = Node.new(value)
         node.next_node = current.next_node
         current.next_node = node
         return
       end
       count += 1
       current = current.next_node
     end
   end
  end
end
