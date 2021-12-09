dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-07.txt"

crab_positions = File.readlines(input_filename).first.strip.split(',').map(&:to_i)
crabs = crab_positions.group_by(&:to_i).transform_values(&:length)
positions = crabs.keys.minmax

def problem1(crabs, positions)
  (positions.first..positions.last).map do |target_position|
    target_fuel = crabs.map do |position, count|
      (target_position - position).abs * count
    end.sum
  end.min
end

def problem2(crabs, positions)
  (positions.first..positions.last).map do |target_position|
    target_fuel = crabs.map do |position, count|
      if target_position == position
        0
      else
        (1..(target_position - position).abs).to_a.sum * count
      end
    end.sum
  end.min
end

puts "Problem 1: #{problem1(crabs.dup, positions)}"
puts "Problem 2: #{problem2(crabs.dup, positions)}"
