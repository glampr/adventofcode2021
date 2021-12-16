dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-16.txt"

bits = File.readlines(input_filename).map(&:strip).first.split('').map { |hex| hex.to_i(16).to_s(2).rjust(4, '0') } .join

@versions_sum = 0

def decode_bits(bits)
  result = []

  while !bits.empty? && bits != '0' * bits.length do
    result << decode_package(bits)
  end

  result
end

def decode_package(bits)
  version = bits.slice!(0, 3).to_i(2)
  type_id = bits.slice!(0, 3).to_i(2)

  @versions_sum += version

  if type_id == 4
    decode_literal(bits).to_i(2)
  else
    operators = decode_operand(bits)

    case type_id
    when 0 # sum
      operators.sum
    when 1 # product
      operators.reduce(:*)
    when 2 # min
      operators.min
    when 3 # max
      operators.max
    when 5 # >
      operators.first > operators.last ? 1 : 0
    when 6 # <
      operators.first < operators.last ? 1 : 0
    when 7 # ==
      operators.first == operators.last ? 1 : 0
    else raise 'invalid packet'
    end
  end
end

def decode_operand(bits)
  length_type_id = bits.slice!(0, 1)

  if length_type_id == '0'
    total_length_in_bits = bits.slice!(0, 15).to_i(2)
    subpackage_bits = bits.slice!(0, total_length_in_bits)
    decode_bits(subpackage_bits)
  elsif length_type_id == '1'
    subpackets_immediately_contained_count = bits.slice!(0, 11).to_i(2)
    subpackets_immediately_contained_count.times.map { decode_package(bits) } .flatten(1)
  end
end

def decode_literal(bits)
  if bits.slice!(0, 1) == '1'
    decode_literal_digit(bits).to_s << decode_literal(bits)
  else
    decode_literal_digit(bits)
  end
end

def decode_literal_digit(bits)
  bits.slice!(0, 4)
end

def problem1(bits)
  decode_bits(bits)
  @versions_sum
end

def problem2(bits)
  decode_bits(bits).first
end

puts "Problem 1: #{problem1(bits.dup)}"
puts "Problem 2: #{problem2(bits.dup)}"
