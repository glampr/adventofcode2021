dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-20.txt"

lines = File.readlines(input_filename).map(&:strip)

algorithm = lines.shift

lines.shift

image = {}

lines.each_with_index do |line, row_index|
  line.chars.each_with_index do |char, col_index|
    image[[row_index, col_index]] = char
  end
end

def surrounding_pixels(coords)
  row, col = coords

  [].tap do |indices|
    indices << [row - 1, col - 1]
    indices << [row - 1, col    ]
    indices << [row - 1, col + 1]
    indices << [row    , col - 1]
    indices << [row    , col    ]
    indices << [row    , col + 1]
    indices << [row + 1, col - 1]
    indices << [row + 1, col    ]
    indices << [row + 1, col + 1]
  end
end

def surrounding_pixels_integer_value(image, coords, unknown)
  indices = surrounding_pixels(coords)

  number = indices.map { |index| {'.' => 0, '#' => 1}[image[index] || unknown] }.join

  number.to_i(2)
end

def extend_initial_image(image, extension)
  image.keys.each do |coords|
    surrounding_pixels(coords).each do |_coords|
      image[_coords] = extension unless image.key?(_coords)
    end
  end
  image
end

def print_image(image)
  min_col = nil
  max_col = nil

  lines = image.sort_by { |coords, pixel| coords }.to_h.group_by do |(row_index, col_index), pixel|
    min_col = [min_col, col_index].compact.min
    max_col = [max_col, col_index].compact.max

    row_index
  end

  canvas = lines.map do |coords, line|
    line_str = "_" * (max_col - min_col)
    line.to_h.each do |(row_index, col_index), pixel|
      line_str[col_index - min_col] = pixel
    end
    line_str
  end

  canvas.each { |cl| puts cl }
  [canvas.length, canvas.first.length]
end

def problem0(image, algorithm, times)
  extend_initial_image(image, '.')
  # puts "Initial image"
  # pp print_image(image)

  times.times do |step|
    surrounded_with = (algorithm[0] == '.') ? '.' : ['.', '#'][(step % 2)]
    extending_with = (algorithm[0] == '.') ? '.' : ['#', '.'][(step % 2)]

    next_image = {}

    image.each do |coords, pixel|
      pixel_value = surrounding_pixels_integer_value(image, coords, surrounded_with)
      next_pixel_value = algorithm[pixel_value]
      next_image[coords] = next_pixel_value
    end

    image = extend_initial_image(next_image, extending_with)
    puts "After step #{step + 1} (extended with #{extending_with})"
    # pp print_image(image)
  end

  image.count { |coords, pixel| pixel == '#' }
end

def problem1(image, algorithm, times)
  problem0(image, algorithm, times)
end

def problem2(image, algorithm, times)
  problem0(image, algorithm, times)
end

puts "Problem 1: #{problem1(image.dup, algorithm, 2)}"
puts "Problem 2: #{problem2(image.dup, algorithm, 50)}"
