class Factoids
  KEY = :factoids

  def self.all(&block)
    Basil::Storage.with_storage do |store|
      yield(store[KEY] ||= {})
    end
  end

  def self.get(key)
    all { |facts| facts[key] }
  end
end

# allows canned-response plugins to be added run-time by anyone
Basil.respond_to(/^(\w+) is <(reply|say)>(.+)/) {

  key    = @match_data[1]
  action = @match_data[2]
  fact   = @match_data[3]

  Factoids.all do |facts|
    facts[key] = {
      :action    => action,
      :fact      => fact,
      :created   => Time.now,
      :by        => @msg.from_name,
      :requested => 0,
      :locked    => false # TODO
    }
  end

  @msg.say 'Ta-da!'

}.description = 'store a new factoid (or overwrite existing)'

Basil::Plugin.respond_to(/^\w+$/) {

  key = @match_data[0]

  Factoids.all do |facts|
    if fact = facts[key]
      @msg.send(fact[:action], fact[:fact])
      fact[:requested] += 1
    end
  end

}

Basil.respond_to(/^factinfo (\w+)$/) {

  key = @match_data[1]

  if fact = Factoids.get(key)
    @msg.say "fact #{key}: created #{fact[:created]} by #{fact[:by]}, requested #{fact[:requested]} time(s)."
    @msg.say "<#{fact[:action]}> #{fact[:fact]}"
  end

}.description = 'give information about a factoid'

Basil.respond_to(/^(del|rm) ?fact(oid)? (\w+)$/) {

  Factoids.all do |facts|
    facts.delete(@match_data[3])
  end

  @msg.say 'Ta-da!'

}.description = 'remove a factoid'
