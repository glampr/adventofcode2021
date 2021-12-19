require 'json'

dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-18.txt"

lines = File.readlines(input_filename).map(&:strip).map do |line|
  JSON.parse(line)
end

SnailfishNumber = Struct.new(:level, :left, :right) do
  attr_accessor :parent
  attr_accessor :value
  attr_accessor :prv
  attr_accessor :nxt

  def initialize(level, left, right)
    super(level, convert(left, level), convert(right, level))
  end

  def magnitude
    3 * (left.is_a?(Numeric) ? left : left.magnitude) + 2 * (right.is_a?(Numeric) ? right : right.magnitude)
  end

  def complex?
    left.is_a?(SnailfishNumber) && right.is_a?(SnailfishNumber)
  end

  def has_number?
    left.is_a?(Numeric) || right.is_a?(Numeric)
  end

  def form_print
    "[#{left.is_a?(SnailfishNumber) ? left.form_print : left},#{right.is_a?(SnailfishNumber) ? right.form_print : right}]"
  end

  def convert(node, node_level)
    return node if node.is_a?(Numeric)
    return SnailfishNumber.new(node_level + 1, *node) if node.is_a?(Array)

    node.level = node_level + 1
    child = convert(node.left, node.level)
    child.parent = node if child.is_a?(SnailfishNumber)
    child = convert(node.right, node.level)
    child.parent = node if child.is_a?(SnailfishNumber)
    node
  end

  def postorder(list)
    if left.is_a?(SnailfishNumber)
      left.postorder(list)
    else
      list << [self, left]
    end

    if right.is_a?(SnailfishNumber)
      right.postorder(list)
    else
      list << [self, right]
    end
  end

  def +(other)
    puts "AADDDDDDINNNGGG" if @debug

    result = SnailfishNumber.new(0, self, other)
    pp result if @debug

    loop do
      action = result.explode! || result.split!
      break if !action
    end

    result
  end

  def explode!
    list = postorder([])

    node = find_first_level_4(list)
    return false if node.nil?

    puts "Exploding" if @debug
    pp node if @debug

    action = false

    postorder_index = list.find_index([node, node.left])

    # do left
    prv_left = nil
    index = postorder_index.downto(0).each do |index|
      next if list[index].first.equal?(node) # object reference equality
      if list[index].first.has_number?
        prv_left = list[index].first
        break index
      end
    end

    if !prv_left.nil?
      action = true

      puts "Left (#{index}): #{prv_left.inspect}" if @debug

      if prv_left.right.is_a?(Numeric)
        prv_left.right += node.left
      elsif prv_left.left.is_a?(Numeric)
        prv_left.left += node.left
      end
    else
      puts "Left was nil" if @debug
    end

    postorder_index = list.find_index([node, node.right])

    # do right
    nxt_right = nil
    index = postorder_index.upto(list.length - 1).each do |index|
      next if list[index].first.equal?(node) # object reference equality
      if list[index].first.has_number?
        nxt_right = list[index].first
        break index
      end
    end

    if !nxt_right.nil?
      action = true

      puts "Right (#{index}): #{nxt_right.inspect}" if @debug

      if nxt_right.left.is_a?(Numeric)
        nxt_right.left += node.right
      elsif nxt_right.right.is_a?(Numeric)
        nxt_right.right += node.right
      end
    else
      puts "Right was nil" if @debug
    end

    # do node
    if node.parent.left == node
      node.parent.left = 0
    elsif node.parent.right == node
      node.parent.right = 0
    end

    puts "After" if @debug
    pp form_print if @debug
    puts if @debug

    action
  end

  def split!
    list = postorder([])

    node = find_first_level_4(list)
    return false if !node.nil?

    node = find_first_larger_than_10(list)
    return false if node.nil?

    puts "Splitting" if @debug
    pp node if @debug

    if node.left.is_a?(Numeric) && node.left >= 10
      puts "splitting #{node.left} => #{node.left / 2}, #{node.left - node.left / 2}" if @debug
      node.left = SnailfishNumber.new(node.level + 1, node.left / 2, node.left - node.left / 2)
      node.left.parent = node
    elsif node.right.is_a?(Numeric) && node.right >= 10
      puts "splitting #{node.right} => #{node.right / 2}, #{node.right - node.right / 2}" if @debug
      node.right = SnailfishNumber.new(node.level + 1, node.right / 2, node.right - node.right / 2)
      node.right.parent = node
    end

    puts "After" if @debug
    pp form_print if @debug
    puts if @debug

    true
  end

  def find_first_level_4(list)
    node, value = list.detect { |node, value| node.level == 4 }
    return node
  end

  def find_first_larger_than_10(list)
    node, value = list.detect { |node, value| value >= 10 }
    return node

    # Original idea!
    # Does not work, should continue exploring left is available
    # e.g. it should choose 10 not 20
    #      x
    #    /   \
    #   x    20
    #  / \
    # 9  10
    # This has to also use the post-order traversing
    #
    # return self if left.is_a?(Numeric) && left >= 10
    # return self if right.is_a?(Numeric) && right >= 10

    # (left.is_a?(SnailfishNumber) && left.find_first_larger_than_10) ||
    # (right.is_a?(SnailfishNumber) && right.find_first_larger_than_10) ||
    # nil
  end
end

def problem1(lines)
  numbers = lines.map { |line| SnailfishNumber.new(0, *line) }

  first_number = numbers.shift

  result = numbers.reduce(first_number, :+)
  result.form_print

  result.magnitude
end

def problem2(lines)
  numbers = lines.map { |line| SnailfishNumber.new(0, *line) }

  permutations = lines.permutation(2).map do |line1, line2|
    result = SnailfishNumber.new(0, *line1) + SnailfishNumber.new(0, *line2)
    result.magnitude
  end.max
end

puts "Problem 1: #{problem1(lines.dup)}"
puts "Problem 2: #{problem2(lines.dup)}"
