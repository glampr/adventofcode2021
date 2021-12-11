dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-10.txt"

lines = File.readlines(input_filename).map(&:strip)

matches = {
  ')' => '(',
  ']' => '[',
  '}' => '{',
  '>' => '<'
}.freeze

points = {
  ')' => 3,
  ']' => 57,
  '}' => 1197,
  '>' => 25137
}.freeze

points2 = {
  ')' => 1,
  ']' => 2,
  '}' => 3,
  '>' => 4
}.freeze

def problem1(lines, points, matches)
  corrupt_indices = []

  scores = lines.map.with_index do |line, i|
    opens = []

    symbol = line.chars.detect do |symbol|
      if matches.values.include?(symbol)
        opens << symbol
        false
      elsif matches.keys.include?(symbol)
        if opens[-1] == matches[symbol]
          opens.pop
          false
        else
          corrupt_indices << i
          symbol
        end
      end
    end

    points[symbol] unless symbol.nil?
  end

  corrupt_indices.reverse.each { |i| lines.delete_at(i) }

  scores.compact.sum
end

def problem2(lines, points, matches)
  invert_matches = matches.invert

  fixes = lines.map.with_index do |line, i|
    opens = []

    line.chars.each do |symbol|
      if matches.values.include?(symbol)
        opens << symbol
      elsif matches.keys.include?(symbol)
        opens.pop if opens[-1] == matches[symbol]
      end
    end

    opens.reverse.map { |c| invert_matches[c] }
  end

  fix_points = fixes.map do |fix|
    fix.reduce(0) do |memo, char_fix|
      memo * 5 + points[char_fix]
    end
  end

  fix_points.sort!
  fix_points[(fix_points.length / 2).ceil]
end

puts "Problem 1: #{problem1(lines, points, matches)}"
puts "Problem 2: #{problem2(lines, points2, matches)}"
