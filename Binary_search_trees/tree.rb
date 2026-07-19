require_relative 'node'

class Tree
  attr_accessor :root

  def initialize(array)
    @root = build_tree(array)
  end
  private def build_tree(arr)
    return nil if arr.empty?
    arr = arr.sort.uniq
    mid = arr.length / 2
    Node.new(arr[mid], build_tree(arr[0...mid]), build_tree(arr[mid + 1..-1]))
  end
  def pretty_print(node = @root, prefix = '', is_left: true)
    return unless node

    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", is_left: false)
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", is_left: true)
  end

  def include?(value, node = @root)
    return false if node.nil?
    return true if value == node.data
    if value < node.data
      include?(value, node.left)
    else
      include?(value, node.right)
    end
  end

  def insert(value, node = @root)
    return Node.new(value) if node.nil?
    if value < node.data
      node.left = insert(value, node.left)
    elsif value > node.data
      node.right = insert(value, node.right)
    end
    node
  end

  def delete(value, node = @root)
    return nil if node.nil?
    if value < node.data
      node.left = delete(value, node.left)
    elsif value > node.data
      node.right = delete(value, node.right)
    else
      return node.right if node.left.nil?
      return node.left if node.right.nil?
      successor = find_min(node.right)
      node.data = successor.data
      node.right = delete(successor.data, node.right)
    end
    node
  end
  private def find_min(node)
    node = node.left while node.left
    node
  end
  def level_order()
    return to_enum(:level_order) unless block_given?
    queue = [@root]
    until queue.empty?
      node = queue.shift
      yield node.data
      queue.push(node.left) if node.left
      queue.push(node.right) if node.right
    end

    self
  end
  def inorder()
    return to_enum(:inorder) unless block_given?
    stack = []
    current = @root
    until stack.empty? && current.nil?
      while current
        stack.push(current)
        current = current.left
      end
      current = stack.pop
      yield current.data
      current = current.right
    end

    self
  end

  def preorder()
    return to_enum(:preorder) unless block_given?
    stack = [@root]
    until stack.empty?
      current = stack.pop
      next if current.nil?
      yield current.data
      stack.push(current.right) if current.right
      stack.push(current.left) if current.left
    end
    self
  end
  def postorder
    return to_enum(:postorder) unless block_given?
    stack = [@root]
    result = []

    until stack.empty?
      node = stack.pop
      next if node.nil?
      result.unshift(node.data)
      stack.push(node.left) if node.left
      stack.push(node.right) if node.right
    end

    result.each { |data| yield data }
    self
  end
  def height(value, node = @root)
    target = find_node(value, node)
    return nil if target.nil?
    height_from(target)
  end

  def depth(value, node = @root, edges = 0)
    return nil if node.nil?
    return edges if node.data == value
    value < node.data ? depth(value, node.left, edges + 1) : depth(value, node.right, edges + 1)
  end
  def balanced?(node = @root)
    return true if node.nil?
    left_height = height_from(node.left)
    right_height = height_from(node.right)
    (left_height - right_height).abs <= 1 && balanced?(node.left) && balanced?(node.right)
  end
  def rebalance
    return self if balanced?
    values = []
    inorder { |data| values << data }
    @root = build_tree(values)
    self
  end

  private

  def find_node(value, node)
    return nil if node.nil?
    return node if node.data == value
    value < node.data ? find_node(value, node.left) : find_node(value, node.right)
  end

  def height_from(node)
    return -1 if node.nil?
    1 + [height_from(node.left), height_from(node.right)].max
  end

end
