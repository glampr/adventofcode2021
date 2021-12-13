dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-13.txt"

Dot = Struct.new(:x, :y, :value) do
  def xy
    [x, y]
  end
end

Paper = Struct.new(:name) do
  attr_accessor :dots
  attr_accessor :min_x
  attr_accessor :min_y
  attr_accessor :max_x
  attr_accessor :max_y

  def initialize(name)
    super(name)
    @dots = {}
    @min_x = nil
    @max_x = nil
    @min_y = nil
    @max_y = nil
  end

  def min_max
    {x: [@min_x, @max_x], y: [@min_y, @max_y]}
  end

  def add(dot)
    value = @dots[dot.xy]&.value.to_i
    dot.value += value
    @dots[dot.xy] = dot

    @min_x ||= dot.x
    @min_x = [dot.x, @min_x].min

    @max_x ||= dot.x
    @max_x = [dot.x, @max_x].max

    @min_y ||= dot.y
    @min_y = [dot.y, @min_y].min

    @max_y ||= dot.y
    @max_y = [dot.y, @max_y].max
  end

  def fold(fold)
    new_paper = Paper.new(name + 1)

    if fold.up?
      @dots.each do |(x,y), dot|
        if dot.y > fold.line
          offset_down = dot.y - fold.line
          new_dot = Dot.new(x, fold.line - offset_down, 1)
          new_paper.add(new_dot)
        elsif dot.y < fold.line
          new_paper.add(Dot.new(x, y, 1))
        end
      end
    elsif fold.left?
      @dots.each do |(x,y), dot|
        if dot.x > fold.line
          offset_right = dot.x - fold.line
          new_dot = Dot.new(fold.line - offset_right, y, 1)
          new_paper.add(new_dot)
        elsif dot.x < fold.line
          new_paper.add(Dot.new(x, y, 1))
        end
      end
    end

    new_paper
  end
end

Fold = Struct.new(:axis, :line) do
  def up?
    axis == 'y'
  end

  def left?
    axis == 'x'
  end
end

paper = Paper.new(0)
folds = []
mode = :dots

lines = File.readlines(input_filename).map(&:strip).map do |line|
  if !line.empty? && mode == :dots
    x, y = line.split(',').map(&:to_i)
    paper.add(Dot.new(x, y, 1))
  end

  mode = :folds if line.empty?

  if mode == :folds && !line.empty?
    fold = line.delete('fold along ').split('=')
    folds << Fold.new(fold.first, fold.last.to_i)
  end
end

def problem1(paper, folds)
  fold = folds.first
  paper.fold(fold).dots.length
end

def problem2(paper, folds)
  final_paper = paper

  folds.each do |fold|
    final_paper = final_paper.fold(fold)
  end

  paper_dots = []

  (final_paper.min_x..final_paper.max_x).each do |x|
    (final_paper.min_y..final_paper.max_y).each do |y|
      paper_dots[y] ||= []
      paper_dots[y][x] = final_paper.dots[[x, y]].nil? ? ' ' : '◼︎'
    end
  end

  puts paper_dots.map(&:join).join("\n")

  nil
end

puts "Problem 1: #{problem1(paper.dup, folds)}"
puts "Problem 2: #{problem2(paper.dup, folds)}"
