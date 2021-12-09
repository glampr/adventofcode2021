require 'set'

dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-08.txt"

lines = File.readlines(input_filename).map do |line|
  connections, output_values = line.split('|').map(&:strip)
  [
    connections.split(' ').map { |connection| connection.chars.sort.join },
    output_values.split(' ').map { |value| value.chars.sort.join }
  ]
end

def problem1(lines)
  easy = Set.new([2, 3, 4, 7])

  lines.map do |line|
    connections, output_values = line
    output_values
    output_values.count { |value| easy.include?(value.length) }
  end.sum
end

def problem2(lines)
  lines.map do |line|
    map = {}
    connections, output_values = line

    map[1] = connections.detect { |c| c.length == 2 }
    connections.delete(map[1])

    map[7] = connections.detect { |c| c.length == 3 }
    connections.delete(map[7])

    map[4] = connections.detect { |c| c.length == 4 }
    connections.delete(map[4])

    map[8] = connections.detect { |c| c.length == 7 }
    connections.delete(map[8])

    map[9] = connections.select do |c|
      c.length == 6 && map[8].dup.delete(c).delete(map[4]).length == 1
    end
    raise 'Multiple 9' if map[9].length > 1
    map[9] = map[9].first
    connections.delete(map[9])

    map[0] = connections.select do |c|
      c.length == 6 && map[8].dup.delete(c).delete(map[7]).length == 1
    end
    raise 'Multiple 0' if map[0].length > 1
    map[0] = map[0].first
    connections.delete(map[0])

    map[6] = connections.select do |c|
      c.length == 6 && map[8].dup.delete(c).length == 1
    end
    raise 'Multiple 6' if map[6].length > 1
    map[6] = map[6].first
    connections.delete(map[6])

    map[5] = connections.select do |c|
      c.length == 5 && map[8].dup.delete(c).delete(map[6]).length == 1
    end
    raise 'Multiple 5' if map[5].length > 1
    map[5] = map[5].first
    connections.delete(map[5])

    map[2] = connections.select do |c|
      c.length == 5 && map[8].dup.delete(c).delete(map[7]).length == 1
    end
    raise 'Multiple 2' if map[2].length > 1
    map[2] = map[2].first
    connections.delete(map[2])

    map[3] = connections.pop

    raise 'oops1' if map[3].length != 5
    raise 'oops2' unless connections.empty?

    map.invert.values_at(*output_values).join.to_i
  end.sum
end

puts "Problem 1: #{problem1(lines.dup)}"
puts "Problem 2: #{problem2(lines.dup)}"
