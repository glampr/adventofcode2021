dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-05.txt"

lines = File.readlines(input_filename).map(&:strip)

Point = Struct.new(:x, :y)

Path = Struct.new(:point1, :point2) do
  def straight_line?
    point1.x == point2.x || point1.y == point2.y
  end

  def all_points
    points = []

    point_min_x, point_max_x = [point1, point2].minmax_by(&:x)
    point_min_y, point_max_y = [point1, point2].minmax_by(&:y)

    if point1.x == point2.x
      (point_min_y.y..point_max_y.y).each do |y|
        points << Point.new(point_min_y.x, y)
      end
    elsif point1.y == point2.y
      (point_min_x.x..point_max_x.x).each do |x|
        points << Point.new(x, point_min_x.y)
      end
    else
      xs = (point_min_x.x..point_max_x.x).to_a
      ys = (point_min_y.y..point_max_y.y).to_a

      xs = xs.reverse if point1.x == point_max_x.x
      ys = ys.reverse if point1.y == point_max_y.y

      xs.zip(ys).each do |(x, y)|
        points << Point.new(x, y)
      end
    end

    points
  end
end

paths = lines.map do |line|
  x1, y1, x2, y2 = line.scan(/(\d+),(\d+) -> (\d+),(\d+)/).first.map(&:to_i)
  Path.new(Point.new(x1, y1), Point.new(x2, y2))
end

def problem1(paths)
  map = []

  paths.select(&:straight_line?).each do |path|
    path.all_points.each do |point|
      map[point.x] ||= []
      map[point.x][point.y] ||= 0
      map[point.x][point.y] += 1
    end
  end

  map.sum do |row|
    row.to_a.count do |cell|
      cell.to_i > 1
    end
  end
end

def problem2(paths)
  map = []

  paths.each do |path|
    path.all_points.each do |point|
      map[point.x] ||= []
      map[point.x][point.y] ||= 0
      map[point.x][point.y] += 1
    end
  end

  map.sum do |row|
    row.to_a.count do |cell|
      cell.to_i > 1
    end
  end
end


puts "Problem 1: #{problem1(paths)}"
puts "Problem 2: #{problem2(paths)}"
