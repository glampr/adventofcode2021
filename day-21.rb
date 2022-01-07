require 'benchmark'
BENCHMARKS = Hash.new(0)

PLAYER1  =    8
PLAYER2  =   10

def format_number(number)
  num_groups = number.to_s.chars.to_a.reverse.each_slice(3)
  num_groups.map(&:join).join(',').reverse
end

ROLLS = {
  '1-1-1' => 3,
  '1-1-2' => 4,
  '1-1-3' => 5,
  '1-2-1' => 4,
  '1-2-2' => 5,
  '1-2-3' => 6,
  '1-3-1' => 5,
  '1-3-2' => 6,
  '1-3-3' => 7,
  '2-1-1' => 4,
  '2-1-2' => 5,
  '2-1-3' => 6,
  '2-2-1' => 5,
  '2-2-2' => 6,
  '2-2-3' => 7,
  '2-3-1' => 6,
  '2-3-2' => 7,
  '2-3-3' => 8,
  '3-1-1' => 5,
  '3-1-2' => 6,
  '3-1-3' => 7,
  '3-2-1' => 6,
  '3-2-2' => 7,
  '3-2-3' => 8,
  '3-3-1' => 7,
  '3-3-2' => 8,
  '3-3-3' => 9,
}

SUMS_WINS = ROLLS.values.group_by(&:to_i).transform_values(&:length)
# {
#   3 => 1,
#   4 => 3,
#   5 => 6,
#   6 => 7,
#   7 => 6,
#   8 => 3,
#   9 => 1,
# }

Die = Struct.new(:current, :rolls) do
  def roll
    self.current += 1
    self.current = 1 if current == 101

    self.rolls += 1
  end
end

Player = Struct.new(:name, :position, :score) do
  def move(steps)
    self.position = (position + steps - 1) % 10 + 1
    self.score += position

    self
  end

  def duplicate_and_move(steps)
    self.class.new(name, position, score).move(steps)
  end
end

Universe = Struct.new(:playing, :waiting, :multi) do
  def expand(metaverse, winning_universes, winscore)
    SUMS_WINS.count do |sum, copies|
      universe = self.class.new(waiting, playing.duplicate_and_move(sum), copies * multi)

      if universe.waiting.score >= winscore
        winning_universes[universe.waiting.name] += universe.multi

        next
      end

      metaverse[universe.hash_id] = universe
    end
  end

  def hash_id
    @hash_id ||= begin
      if playing.name == 'p1'
        player1 = playing
        player2 = waiting
      else
        player2 = playing
        player1 = waiting
      end

      "#{player1.position}-#{player1.score}-#{player2.position}-#{player2.score}"
    end
  end
end

def problem1(winscore)
  player1 = Player.new('p1', PLAYER1, 0)
  player2 = Player.new('p2', PLAYER2, 0)
  die = Die.new(0, 0)

  loop do
    moves = 3.times.map { die.roll } .sum
    player1.move(moves)
    break if player1.score >= winscore

    moves = 3.times.map { die.roll } .sum
    player2.move(moves)
    break if player2.score >= winscore
  end

  losing_score = [player1.score, player2.score].min
  puts "Losing score: #{losing_score} * die rolls #{die.rolls}"
  losing_score * die.rolls
end

def problem2(winscore)
  winning_universes = {'p1' => 0, 'p2' => 0}
  player1 = Player.new('p1', PLAYER1, 0)
  player2 = Player.new('p2', PLAYER2, 0)
  universes = { "#{PLAYER1}-0-#{PLAYER2}-0" => Universe.new(player1, player2, 1) }

  counter = 0

  while !universes.empty?
    new_universes_count = 0

    BENCHMARKS['loop'] += Benchmark.realtime do
      next_universe_key = universes.keys.last # last simulates DFS (faster), first simulates BFS (huge memory)
      next_universe = universes.delete(next_universe_key)

      new_universes_count = next_universe.expand(universes, winning_universes, winscore)
    end

    puts ["Time: #{BENCHMARKS['loop'].to_f.round}",
        "Counter: #{format_number counter}",
        "Remaining: #{format_number universes.length}",
        "Newly added: #{format_number new_universes_count}",
        "P1: #{format_number winning_universes['p1']}",
        "P2: #{format_number winning_universes['p2']}"
      ].inspect if (counter += 1) % 100_000 == 0
  end

  winning_universes.values.max
end

puts "Problem 1: #{problem1(1000)}"
puts "Problem 2: #{problem2(21)}"
