dir = File.dirname(__FILE__)
input_filename = "#{dir}/day-04.txt"

lines = File.readlines(input_filename).map(&:strip)

Board = Struct.new(:rows, :columns) do
  def pick(number)
    rows.each do |row|
      row.delete(number)
    end

    columns.each do |column|
      column.delete(number)
    end
  end

  def wins?
    rows.any?(&:empty?) || columns.any?(&:empty?)
  end

  def score
    rows.flatten.sum
  end
end

draws = lines.shift.split(',').map(&:to_i)

board_defs = lines.slice_before { |line| line == '' } .to_a
board_defs.each(&:shift)

boards = board_defs.map do |board_def|
  rows = board_def.map do |row|
    row.split(/\s+/).map(&:to_i)
  end
  columns = rows.transpose

  Board.new(rows, columns)
end

def problem1(draws, boards)
  score = draws.each do |draw|
    winning_board = boards.detect do |board|
      board.pick(draw)
      board.wins?
    end

    break winning_board.score * draw unless winning_board.nil?
  end
end

def problem2(draws, boards)
  score = draws.each do |draw|
    winning, still_in_the_game = boards.partition do |board|
      board.pick(draw)
      board.wins?
    end

    if still_in_the_game.empty?
      break winning.last.score * draw
    else
      boards -= winning
    end
  end
end


puts "Problem 1: #{problem1(draws, boards)}"
puts "Problem 2: #{problem2(draws, boards)}"
