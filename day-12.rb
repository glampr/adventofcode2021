require 'rbgraph'
require 'set'

dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-12.txt"

Path = Struct.new(:nodes) do
  attr_accessor :double

  def initialize(nodes)
    super(nodes)

    @hash ||= {}
    nodes.each_with_index do |node, i|
      @hash[get_id(node)] ||= []
      @hash[get_id(node)] << i
    end
  end

  def count(node)
    @hash[get_id(node)]&.length.to_i
  end

  def double
    @hash.detect { |k, v| k.downcase == k && v.length == 2 } &.first
  end

  def get_id(node)
    node.send(:id) rescue node.to_s
  end
end

graph = Rbgraph::UndirectedGraph.new
start = nil
finish = nil

lines = File.readlines(input_filename).map(&:strip).map do |line|
  cave1_id, cave2_id = line.split('-')
  cave1 = graph.add_node!(cave1_id, {type: cave1_id == cave1_id.upcase ? :big : :small})
  cave2 = graph.add_node!(cave2_id, {type: cave2_id == cave2_id.upcase ? :big : :small})

  start ||= [cave1, cave2].detect { |cave| cave.id == 'start' }
  finish ||= [cave1, cave2].detect { |cave| cave.id == 'end' }

  path = graph.add_edge!(cave1, cave2)
end

def traverse(graph, start, finish)
  paths_exhausted = false

  paths = [Path.new([start])]

  while !paths_exhausted
    next_paths = []

    paths.each do |path|
      last_node = path.nodes.last
      if last_node.id == 'end'
        next_paths << path
        next
      end

      neighbors = []

      last_node.edges.each do |edge_id, edge|
        neighbor = edge.other_node(last_node)
        next if neighbor.id == 'start'
        next if yield(path, neighbor)

        neighbors << neighbor
      end

      neighbors.each do |new_node|
        next_paths << Path.new(path.nodes + [new_node])
      end
    end

    paths_exhausted = next_paths.all? { |path| path.nodes.last.id == 'end' }
    paths = next_paths
  end

  paths.length
end

puts "Problem 1: #{traverse(graph, start, finish) do |path, neighbor|
  neighbor.data[:type] == :small && path.count(neighbor) == 1
end}"
puts "Problem 2: #{traverse(graph, start, finish) do |path, neighbor|
  neighbor.data[:type] == :small && path.count(neighbor) >= (path.double.nil? ? 2 : 1)
end}"
