dir = File.dirname(__FILE__)
input_filename = "#{dir}/problem01.txt"

lines = File.readlines(input_filename)

def problem1(lines)
  counter = 0

  lines.each_cons(2) do |line1, line2|
    puts "Line: #{line1.to_i}, #{line2.to_i}"
    counter += 1 if line1.to_i < line2.to_i
  end

  counter
end

def problem2(lines)
  counter = 0

  lines.each_cons(3).to_a.each_cons(2) do |group1, group2|
    group1.map!(&:to_i)
    group2.map!(&:to_i)

    sum1 = group1.sum
    sum2 = group2.sum
    puts "Line: #{group1.inspect}=#{sum1}, #{group2.inspect}=#{sum2}"
    counter += 1 if sum1 < sum2
  end

  counter
end


puts "Problem 1: #{problem1(lines)}"
puts "Problem 2: #{problem2(lines)}"
