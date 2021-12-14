dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-14.txt"

lines = File.readlines(input_filename).map(&:strip)

template = lines.shift

lines.shift

instructions = lines.each_with_object({}) do |line, memo|
  find, insert = line.split(' -> ')
  memo[find] = insert
end

def problem1(template, instructions)
  (1..10).each do |step|
    pairs = template.chars.each_cons(2).to_a

    new_pairs = pairs.map do |pair|
      [pair.first, instructions[pair.join]]
    end

    template = new_pairs.join + template.chars.last
  end

  stats = template.chars.group_by(&:to_s).transform_values(&:length)

  minmax = stats.values.minmax
  minmax.last.to_i - minmax.first.to_i
end

def problem2(template, instructions)
  pairs = template.chars.each_cons(2).each_with_object(Hash.new(0)) do |(l1, l2), memo|
    memo[[l1, l2].join] += 1
  end

  letters = template.chars.group_by(&:to_s).transform_values(&:length)
  letters.default = 0

  (1..40).each do |step|
    pairs = pairs.each_with_object(Hash.new(0)) do |(pair, value), memo|
      inserted = instructions[pair]
      letter1, letter2 = pair.split('')

      letters[inserted] += value
      memo[[letter1, inserted].join] += value
      memo[[inserted, letter2].join] += value
    end
  end

  minmax = letters.values.minmax
  minmax.last.to_i - minmax.first.to_i
end

puts "Problem 1: #{problem1(template.dup, instructions)}"
puts "Problem 2: #{problem2(template.dup, instructions)}"
