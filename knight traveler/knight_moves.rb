def knight_moves(start, target)
  queue = [start]
  parent_map = {start => nil}

  while !queue.empty?
    current = queue.shift
    if current == target
      return reconstruct_path(parent_map, start, target)
    end
    neighbors = possible_moves(current)
    neighbors.each do |neighbor|
      if !parent_map.include?(neighbor)
        parent_map[neighbor] = current
        queue.push(neighbor)
      end
    end
  end

end

def reconstruct_path(parent_map, start, goal)
  path = []
  current = goal
  while current != nil do
    path << current
    current = parent_map[current]
  end
  path.reverse
end

def possible_moves(position)
  x, y = position
  moves = [
    [x+1, y+2], [x+1, y-2], [x-1, y+2], [x-1, y-2],
    [x+2, y+1], [x+2, y-1], [x-2, y-1], [x-2, y+1]
  ]
  moves.select { |mx, my| valid?(mx, my) }
end

def valid?(x, y)
  x.between?(0, 7) && y.between?(0, 7)
end
