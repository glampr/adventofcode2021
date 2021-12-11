dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-11.txt"

lines = File.readlines(input_filename).map(&:strip).map do |line|
  line.split('').map(&:to_i)
end

MAX_ROW = lines.length - 1
MAX_COL = lines.first.length - 1

Octopus = Struct.new(:value, :row, :col, :flash_step) do
  attr_accessor :neighbors

  def step_up!(step, flashes)
    self.value += 1 unless flash_step == step

    if value > 9 && flash_step != step
      self.flash_step = step
      self.value = 0
      flashes << 1

      neighbors.each { |n| n.step_up!(step, flashes) }
    end
  end
end

def adjacent_indices(row, col, max_row, max_col)
  [].tap do |indices|
    indices << [row - 1, col - 1] unless row == 0 || col == 0
    indices << [row    , col - 1] unless col == 0
    indices << [row + 1, col - 1] unless row == max_col || col == 0
    indices << [row - 1, col    ] unless row == 0
    indices << [row + 1, col    ] unless row == max_row
    indices << [row - 1, col + 1] unless row == 0 || col == max_col
    indices << [row    , col + 1] unless col == max_col
    indices << [row + 1, col + 1] unless row == max_col || col == max_col
  end
end

cavern = {}

lines.each_with_index do |row, row_index|
  row.each_with_index do |value, col_index|
    cavern[[row_index, col_index]] = Octopus.new(value, row_index, col_index, -1)
  end
end

cavern.values.each do |octopus|
  octopus.neighbors = adjacent_indices(
    octopus.row,
    octopus.col,
    MAX_ROW,
    MAX_COL
  ).map { |coordinates| cavern[coordinates] } .freeze
end

def pp_cavern(lines, cavern)
  lines.each_with_index do |row, row_index|
    row.each_with_index do |value, col_index|
      lines[row_index][col_index] = cavern[[row_index, col_index]].value
    end
  end
  pp lines
end

def problem1(lines, cavern)
  flashes = []

  (1..100).each do |step|
    cavern.each do |_, octopus|
      octopus.step_up!(step, flashes)
    end
  end

  flashes.length
end

def problem2(lines, cavern)
  flashes = []

  step = 101 # pray that there were no simultaneous flashes in problem 1
  loop do
    previous_flashes = flashes.length

    cavern.each do |_, octopus|
      octopus.step_up!(step, flashes)
    end

    new_flashes = flashes.length - previous_flashes
    return step if new_flashes == (MAX_ROW + 1) * (MAX_COL + 1)

    step += 1
  end
end

puts "Problem 1: #{problem1(lines.dup, cavern)}"
puts "Problem 2: #{problem2(lines.dup, cavern)}"
