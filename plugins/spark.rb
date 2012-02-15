# -*- coding: utf-8 -*-
#
# https://gist.github.com/1367091
#
# FIXME: skype/dbus doesn't like the characters?
#
SPARK_TICKS = %w[▁ ▂ ▃ ▄ ▅ ▆ ▇]
Basil.respond_to(/^spark (.+)/) {
  values = @match_data[1].split(/[, ]+/).map { |x| x.to_f }
  min, range, scale = values.min, values.max - values.min, SPARK_TICKS.length - 1
  replies values.map { |x| SPARK_TICKS[(((x - min) / range) * scale).round] }.join
}.description = "turns comma-separated list of numbers (int,float) into sparklines"
