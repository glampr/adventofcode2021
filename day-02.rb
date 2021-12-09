dir = File.dirname(__FILE__)
input_filename = "#{dir}/problem02.txt"

lines = File.readlines(input_filename)

def problem1(lines)
  length = 0
  depth = 0

  lines.each do |line|
    command, movement = line.scan(/(\w+) (\d+)/).first

    case command
    when 'forward' then length += movement.to_i
    when 'down' then depth += movement.to_i
    when 'up' then depth -= movement.to_i
    else raise 'Invalid command!'
    end
  end

  length * depth
end

def problem2(lines)
  length = 0
  depth = 0
  aim = 0

  lines.each do |line|
    command, movement = line.scan(/(\w+) (\d+)/).first

    case command
    when 'forward'
      length += movement.to_i
      depth += aim * movement.to_i
    when 'down' then aim += movement.to_i
    when 'up' then aim -= movement.to_i
    else raise 'Invalid command!'
    end
  end

  length * depth
end


puts "Problem 1: #{problem1(lines)}"
puts "Problem 2: #{problem2(lines)}"
