require 'set'

dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-17.txt"

line = File.readlines(input_filename).map(&:strip).first
target = line.scan(/target area: x=([\d-]+)..([\d-]+), y=([\d-]+)..([\d-]+)/).first.map(&:to_i)
min_x, max_x, min_y, max_y = target

Point = Struct.new(:x, :y, :velocity) do
  attr_accessor :max_y

  def hit?(min_x, max_x, min_y, max_y)
    x.between?(min_x, max_x) && y.between?(min_y, max_y)
  end

  def miss?(min_x, max_x, min_y, max_y)
    return true if x.abs > max_x.abs
    return true if y < min_y
    return true if velocity.vx == 0 && x.abs < min_x.abs

    false
  end

  def move
    self.max_y = [max_y, y].compact.max
    self.x += velocity.vx
    self.y += velocity.vy

    velocity.vx = [0, velocity.vx - 1, velocity.vx + 1][velocity.vx <=> 0]
    velocity.vy -= 1
  end
end

Velocity = Struct.new(:vx, :vy) do
  def initialize(vx, vy)
    super(vx, vy)
    @initial_vx = vx
    @initial_vy = vy
  end

  def initial
    [@initial_vx, @initial_vy]
  end
end

def shoot(point, min_x, max_x, min_y, max_y)
  while !point.miss?(min_x, max_x, min_y, max_y)
    point.move
    return point if point.hit?(min_x, max_x, min_y, max_y)
  end

  nil
end

def test(vx, vy)
  point = Point.new(0, 0, Velocity.new(vx, vy))
  shoot(point, min_x, max_x, min_y, max_y)
end

def problem1(min_x, max_x, min_y, max_y)
  v_max_x = max_x
  v_max_y = 2 * max_x.abs

  v_max_y.downto(0) do |v_y|
    v_max_x.downto(0) do |v_x|
      point = shoot(Point.new(0, 0, Velocity.new(v_x, v_y)), min_x, max_x, min_y, max_y)

      return point.max_y unless point.nil?
    end
  end

  0
end

def problem2(min_x, max_x, min_y, max_y)
  shots = Set.new

  v_max_x = max_x
  v_max_y = 2 * max_x.abs

  v_max_y.downto(-v_max_y) do |v_y|
    v_max_x.downto(0) do |v_x|
      point = shoot(Point.new(0, 0, Velocity.new(v_x, v_y)), min_x, max_x, min_y, max_y)

      shots << point.velocity.initial unless point.nil?
    end
  end

  shots.size
end

puts "Problem 1: #{problem1(min_x, max_x, min_y, max_y)}"
puts "Problem 2: #{problem2(min_x, max_x, min_y, max_y)}"
