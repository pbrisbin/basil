# -*- coding: utf-8 -*-

# basil, you're a bread compartment
# => no, YOU are a bread compartment
#
Basil::Plugin.respond_to(/^you(.*)/) {

  replies "no, YOU#{@match_data[1]}!"

}

#
# basil, call me a taxi
# => fine, you're a taxi.
#
Basil::Plugin.respond_to(/^call me a (.*)/) {

  replies "fine, you're a #{@match_data[1]}."

}

Basil::Plugin.respond_to('beer') {

  replies "someone wanted you to have this (beer)"

}

# https://gist.github.com/1367091
SPARK_TICKS = %w[▁ ▂ ▃ ▄ ▅ ▆ ▇]
Basil::Plugin.respond_to(/spark (.*)/) {
  values = @match_data[1].split(/[, ]+/).map { |x| x.to_f }
  min, range, scale = values.min, values.max - values.min, SPARK_TICKS.length - 1
  replies values.map { |x| SPARK_TICKS[(((x - min) / range) * scale).round] }.join
}.description = "turns comma-separated list of numbers (int,float) into sparklines"
