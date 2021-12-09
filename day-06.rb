dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-06.txt"

lines = File.readlines(input_filename).map(&:strip)

fish = lines.first.split(',').group_by(&:to_i).transform_values(&:length)
fish.default = 0

def problem1(fish, days)
  days.times do |_|
    new_fish = Hash.new(0)

    fish.each do |age, count|
      next if age == 0
      new_fish[age - 1] = count
    end

    new_fish[6] += fish[0]
    new_fish[8] += fish[0]

    fish = new_fish
  end

  fish.values.sum
end

puts "Problem 1: #{problem1(fish.dup, 80)}"
puts "Problem 2: #{problem1(fish.dup, 256)}"
