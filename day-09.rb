dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-09.txt"

lines = File.readlines(input_filename).map { |line| line.strip.split('').map(&:to_i) }

def adjacent_indices(row, col, max_row, max_col)
  [].tap do |indices|
    indices << [row - 1, col] unless row == 0
    indices << [row, col - 1] unless col == 0
    indices << [row + 1, col] unless row == max_row
    indices << [row, col + 1] unless col == max_col
  end
end

def problem1(lines, low_points)
  max_row = lines.length - 1
  max_col = lines.first.length - 1

  risk_levels = []

  lines.each_with_index do |row, row_index|
    row.each_with_index do |point, col_index|
      is_low = adjacent_indices(row_index, col_index, max_row, max_col).all? do |(x, y)|
        point < lines[x][y]
      end

      if is_low
        low_points << [row_index, col_index]
        risk_levels << point + 1
      end
    end
  end

  risk_levels.sum
end

def problem2(lines, low_points)
  max_row = lines.length - 1
  max_col = lines.first.length - 1

  basins = []

  low_points.map do |low_point|
    basin = [[low_point]]

    loop do
      new_points = basin.last.map do |edge_point|
        row_index, col_index = edge_point

        potential = adjacent_indices(row_index, col_index, max_row, max_col)
        potential -= basin.flatten(1)
        potential.select do |(x, y)|
          lines[x][y] < 9 && lines[x][y] >= lines[row_index][col_index]
        end
      end

      new_points = [new_points.flatten(1)]

      break if new_points.flatten.empty?

      basin += new_points
    end

    basins << basin.flatten(1).uniq
  end

  biggest_basins = basins.sort_by(&:length).reverse.take(3)
  biggest_basins.reduce(1) { |memo, basin| memo * basin.length }
end

low_points = []
puts "Problem 1: #{problem1(lines.dup, low_points)}"
puts "Problem 2: #{problem2(lines.dup, low_points)}"
