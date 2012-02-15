Basil.respond_to(/^fight (\S+) (\S+)/) {

  play = lambda do |a,b|
    score_a = (1..9001).to_a.shuffle.first
    score_b = (1..9001).to_a.shuffle.first

    if score_a == score_b
      play.call(a,b)
    else
      "#{a}: #{score_a}, #{b}: #{score_b}"
    end
  end

  score = play.call(@match_data[1], @match_data[2])

  says score

}.description = 'plays out a fictional battle between two combatants'
