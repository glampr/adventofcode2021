require 'rbgraph'
require 'set'

class PriorityQueue
  def initialize
    @elements = [nil]
    @elements_set = Set.new
  end

  def include?(element)
    @elements_set.include?(element)
  end

  def <<(element)
    @elements_set << element
    @elements << element
    # bubble up the element that we just added
    bubble_up(@elements.size - 1)
  end

  def pop
    # exchange the root with the last element
    exchange(1, @elements.size - 1)

    # remove the last element of the list
    max = @elements.pop

    # and make sure the tree is ordered again
    bubble_down(1)
    max
  end

  def bubble_up(index)
    parent_index = (index / 2)

    # return if we reach the root element
    return if index <= 1

    # or if the parent is already greater than the child
    return if @elements[parent_index].data[:distance] <= @elements[index].data[:distance]

    # otherwise we exchange the child with the parent
    exchange(index, parent_index)

    # and keep bubbling up
    bubble_up(parent_index)
  end

  def bubble_down(index)
    child_index = (index * 2)

    # stop if we reach the bottom of the tree
    return if child_index > @elements.size - 1

    # make sure we get the largest child
    not_the_last_element = child_index < @elements.size - 1
    left_element = @elements[child_index]
    right_element = @elements[child_index + 1]
    child_index += 1 if not_the_last_element && right_element.data[:distance] < left_element.data[:distance]

    # there is no need to continue if the parent element is already bigger
    # then its children
    return if @elements[index].data[:distance] <= @elements[child_index].data[:distance]

    exchange(index, child_index)

    # repeat the process until we reach a point where the parent
    # is larger than its children
    bubble_down(child_index)
  end

  def exchange(source, target)
    @elements[source], @elements[target] = @elements[target], @elements[source]
  end
end

dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-15.txt"

lines = File.readlines(input_filename).map(&:strip).map do |line|
  line.split('').map(&:to_i)
end

def build_graph(lines)
  graph = Rbgraph::UndirectedGraph.new
  start = nil
  finish = nil

  lines.each_with_index do |line, i|
    line.each_with_index do |point, j|
      node = graph.add_node!([i, j], {n: point})
      start ||= node
      finish = node
      next if j == 0 && i == 0

      graph.add_edge!(node, graph.nodes[[i - 1, j]], point) if i != 0
      graph.add_edge!(node, graph.nodes[[i, j - 1]], point) if j != 0
    end
  end

  [graph, start, finish]
end

def expand_lines(lines, h)
  max_row = lines.length
  max_col = lines.first.length

  one_line = [0] * max_col * h
  new_lines = []
  (max_row * h).times { new_lines << one_line.dup }

  new_lines.each_with_index do |row, row_index|
    row.each_with_index do |value, col_index|
      inc = col_index / max_col
      inc += row_index / max_row

      new_lines[row_index][col_index] = lines[row_index % max_row][col_index % max_col] + inc
      new_lines[row_index][col_index] -= 9 if new_lines[row_index][col_index] > 9
    end
  end

  new_lines
end

def problem1(lines)
  graph, start, finish = build_graph(lines)

  start.data[:distance] = 0

  priority_queue = PriorityQueue.new
  priority_queue << start

  unvisited_nodes = Set.new(graph.nodes.values)

  while !unvisited_nodes.empty? do
    next_node = priority_queue.pop

    unvisited_nodes.delete(next_node)
    break if next_node.id == finish.id

    next_node.edges.each do |eid, edge|
      neighbor = edge.other_node(next_node)

      if unvisited_nodes.include?(neighbor)
        new_distance = next_node.data[:distance] + neighbor.data[:n]

        if neighbor.data[:distance].nil? || new_distance < neighbor.data[:distance]
          neighbor.data[:distance] = new_distance
          neighbor.data[:prev] = next_node

          priority_queue << neighbor
        end
      end
    end
  end

  finish.data[:distance]
end

def problem2(lines)
  new_lines = expand_lines(lines, 5)
  problem1(new_lines)
end

puts "Problem 1: #{problem1(lines)}"
puts "Problem 2: #{problem2(lines)}"
