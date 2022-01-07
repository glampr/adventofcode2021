require 'set'

dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-22.txt"

Instruction = Struct.new(:op, :x_range, :y_range, :z_range) do
  def on?
    op == 'on'
  end

  def off?
    op.nil?
  end

  def each_cuboid
    x_range.each do |x|
      y_range.each do |y|
        z_range.each do |z|
          yield [x, y, z]
        end
      end
    end
  end

  def ranges_overlap?(r1, r2)
    r1.cover?(r2.first) || r2.cover?(r1.first)
  end

  def includes_point?(point)
    x, y, z = point
    x_range.cover?(x) && y_range.cover?(y) && z_range.cover?(z)
  end

  def includes?(cuboid)
    x_range.cover?(cuboid.x_range) && y_range.cover?(cuboid.y_range) && z_range.cover?(cuboid.z_range)
  end

  def included_by?(cuboid)
    cuboid.includes?(self)
  end

  def intersection(cuboid)
    x_begin = [x_range.begin, cuboid.x_range.begin].max
    x_end = [x_range.end, cuboid.x_range.end].min
    y_begin = [y_range.begin, cuboid.y_range.begin].max
    y_end = [y_range.end, cuboid.y_range.end].min
    z_begin = [z_range.begin, cuboid.z_range.begin].max
    z_end = [z_range.end, cuboid.z_range.end].min

    return nil if [x_begin..x_end, y_begin..y_end, z_begin..z_end].any? { |r| r.size.zero? }

    Instruction.new('intersection', x_begin..x_end, y_begin..y_end, z_begin..z_end)
  end

  def union(cuboid)
    new_x_begin = [x_range.begin, cuboid.x_range.begin].min
    new_x_end = [x_range.end, cuboid.x_range.end].max
    new_y_begin = [y_range.begin, cuboid.y_range.begin].min
    new_y_end = [y_range.end, cuboid.y_range.end].max
    new_z_begin = [z_range.begin, cuboid.z_range.begin].min
    new_z_end = [z_range.end, cuboid.z_range.end].max

    Instruction.new('union', new_x_begin..new_x_end, new_y_begin..new_y_end, new_z_begin..new_z_end)
  end

  # Returns "pieces" of self excluding points covered by cuboid
  def subtract(cuboid)
    common = intersection(cuboid)
    return [] if common.nil?

    x_splits = [
      x_range.begin..(cuboid.x_range.begin - 1), (cuboid.x_range.end + 1)..x_range.end
    ].reject { |r| r.size.zero? }
    y_splits = [
      y_range.begin..(cuboid.y_range.begin - 1), (cuboid.y_range.end + 1)..y_range.end
    ].reject { |r| r.size.zero? }
    z_splits = [
      z_range.begin..(cuboid.z_range.begin - 1), (cuboid.z_range.end + 1)..z_range.end
    ].reject { |r| r.size.zero? }

    results = {}

    x_splits.each do |x_split|
      result = Instruction.new(op, x_split, y_range, z_range)
      next if result.size.zero?
      next if result.hash_id == cuboid.hash_id
      results[result.hash_id] = result
    end

    x_begin = [x_range.begin, cuboid.x_range.begin].max
    x_end = [x_range.end, cuboid.x_range.end].min

    fixed_x_range = x_begin..x_end

    y_splits.each do |y_split|
      result = Instruction.new(op, fixed_x_range, y_split, z_range)
      next if result.size.zero?
      next if result.hash_id == cuboid.hash_id
      results[result.hash_id] = result
    end

    y_begin = [y_range.begin, cuboid.y_range.begin].max
    y_end = [y_range.end, cuboid.y_range.end].min

    fixed_y_range = y_begin..y_end

    z_splits.each do |z_split|
      result = Instruction.new(op, fixed_x_range, fixed_y_range, z_split)
      next if result.size.zero?
      next if result.hash_id == cuboid.hash_id
      results[result.hash_id] = result
    end

    results
  end

  def size
    x_range.size * y_range.size * z_range.size
  end

  def hash_id
    "#{x_range.begin}-#{x_range.end}-#{y_range.begin}-#{y_range.end}-#{z_range.begin}-#{z_range.end}"
  end
end

instructions = File.readlines(input_filename).map do |line|
  args = line.strip.scan(/(on|off) x=(\-?\d+)..(\-?\d+),y=(\-?\d+)..(\-?\d+),z=(\-?\d+)..(\-?\d+)/).first
  op = args.shift
  args.map!(&:to_i)
  Instruction.new(op == 'on' ? 'on' : nil, args[0]..args[1], args[2]..args[3], args[4]..args[5])
end

def problem1(reactor, instructions, boot_cuboid)
  on = 0

  instructions.each do |instruction|
    next if instruction.intersection(boot_cuboid).nil?

    instruction.each_cuboid do |cuboid|
      next if reactor[cuboid] == instruction.op

      if reactor[cuboid].nil? && instruction.op == 'on'
        reactor[cuboid] = 'on'
        on += 1
      elsif reactor[cuboid] == 'on' && instruction.op.nil?
        reactor.delete(cuboid)
        on -= 1
      end
    end
  end

  on
end

def problem2(reactor, instructions)
  instructions = instructions.drop_while(&:off?)
  first_on_instruction = instructions.shift

  ons = { first_on_instruction.hash_id => first_on_instruction }

  while !instructions.empty? do
    next_instruction = instructions.shift

    if next_instruction.on?
      # skip if new on instruction is already included by an existing on
      next if ons.any? { |hash, instruction| instruction.includes?(next_instruction) }
    elsif next_instruction.off?
      # delete if exact match
      ons.delete(next_instruction.hash_id) && next

      # delete if included completely
      ons.delete_if { |hash, instruction| instruction.included_by?(next_instruction) }
    end

    intersecting = ons.select { |hash, instruction| instruction.intersection(next_instruction) }

    intersecting.map do |remove_hash, intersected|
      remaining = intersected.subtract(next_instruction)

      remaining.each do |add_hash, remainder|
        ons[remainder.hash_id] = remainder
      end

      ons.delete(remove_hash)
    end

    ons[next_instruction.hash_id] = next_instruction if next_instruction.on?
  end

  ons.values.map(&:size).sum
end

puts "Problem 1: #{problem1({}, instructions, Instruction.new('boot', -50..50, -50..50, -50..50))}"
puts "Problem 2: #{problem2({}, instructions)}"
