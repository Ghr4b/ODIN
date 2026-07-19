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
# --- Test Cases ---
p knight_moves([0,0], [1,2])
# Output: [[0, 0], [1, 2]]

p knight_moves([0,0], [3,3])
# Output: [[0,0],[2,1],[3,3]] or [[0,0],[1,2],[3,3]].

p knight_moves([3,3], [0,0])
# Output: [[3,3],[2,1],[0,0]] or [[3,3],[1,2],[0,0]].

p knight_moves([0,0], [7,7])
# Output: [[0,0],[2,1],[4,2],[6,3],[4,4],[6,5],[7,7]] or [[0,0],[2,1],[4,2],[6,3],[7,5],[5,6],[7,7]] or other possible shortest paths.
