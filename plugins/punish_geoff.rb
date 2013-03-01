# encoding: UTF-8

MEAN_RESPONSES = [
  "Please shut up Geoff.",
  "That's quite enough.",
  "(yawn)",
  "touché",
  "(highfive)"
]

NICE_RESPONSES = [
  "Gooooooo teeeaam!!!!!!",
  "(y)"
]

MONDAY_RESPONSES = [
  "Shut up, Geoff.",
  "Not today, Geoff.",
  "(n)"
]

Basil.watch_for(/go *team/i) do
  geoff = Basil::Config.geoffs_name

  if geoff && @msg.from == geoff
    if Time.now.wday == 1
      @msg.say MONDAY_RESPONSES.sample
    else
      if rand(100) < 5 # 5% of the time be nice
        @msg.say NICE_RESPONSES.sample
      else
        @msg.say MEAN_RESPONSES.sample
      end
    end
  end
end
