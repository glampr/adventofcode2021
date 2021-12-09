dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-03.txt"

lines = File.readlines(input_filename).map(&:strip)

def most_least_common_bits(lines)
  most_common = ''
  least_common = ''

  columns = lines.map { |line| line.split('') }.transpose

  columns.each do |column|
    #                                        {"1"=>497, "0"=>503}   [["1", 497], ["0", 503]]  ["1", "0"]
    least, most = column.group_by(&:to_s).transform_values(&:length).minmax_by { |k, v| v } .map(&:first)

    most_common << most
    least_common << least
  end

  [most_common, least_common]
end

def problem1(lines)
  binary_gamma, binary_epsilon = most_least_common_bits(lines)

  binary_gamma.to_i(2) * binary_epsilon.to_i(2)
end

def problem2(lines)
  oxygen_lines = lines.dup

  oxygen = oxygen_lines.first.chars.length.times do |bit_index|
    most_common_bits, least_common_bits = most_least_common_bits(oxygen_lines)
    bit = most_common_bits[bit_index] == least_common_bits[bit_index] ? '1' : most_common_bits[bit_index]

    oxygen_lines.reject! { |line| line[bit_index] != bit }
    break oxygen_lines.pop if oxygen_lines.length == 1
  end

  co2_lines = lines.dup
  co2 = co2_lines.first.chars.length.times do |bit_index|
    most_common_bits, least_common_bits = most_least_common_bits(co2_lines)
    bit = most_common_bits[bit_index] == least_common_bits[bit_index] ? '0' : least_common_bits[bit_index]

    co2_lines.reject! { |line| line[bit_index] != bit }
    break co2_lines.pop if co2_lines.length == 1
  end

  raise if oxygen_lines.length > 1
  raise if co2_lines.length > 1

  oxygen.to_i(2) * co2.to_i(2)
end


puts "Problem 1: #{problem1(lines)}"
puts "Problem 2: #{problem2(lines)}"
