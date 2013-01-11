# allows canned-response plugins to be added run-time by anyone
Basil.respond_to(/^(\w+) is <(reply|say)>(.+)/) {

  key    = @match_data[1]
  action = @match_data[2]
  fact   = @match_data[3]

  Basil::Storage.with_storage do |store|
    store[:factoids] ||= {}
    store[:factoids][key] = { :action    => action,
                              :fact      => fact,
                              :created   => Time.now,
                              :by        => @msg.from_name,
                              :requested => 0,
                              :locked    => false } # TODO:
  end

  @msg.say 'Ta-da!'

}.description = 'store a new factoid (or overwrite existing)'

Basil::Plugin.respond_to(/^\w+$/) {

  fact = nil

  Basil::Storage.with_storage do |store|
    store[:factoids] ||= {}
    fact = store[:factoids][@match_data[0]]
    fact[:requested] += 1 if fact
  end

  if fact
    case fact[:action]
    when 'reply' then @msg.reply fact[:fact]
    when 'say'   then @msg.say   fact[:fact]
    else nil
    end
  else
    nil
  end

}

Basil.respond_to(/^factinfo (\w+)$/) {

  key  = @match_data[1]
  fact = nil

  Basil::Storage.with_storage do |store|
    store[:factoids] ||= {}
    fact = store[:factoids][key]
  end

  if fact
    @msg.say "fact #{key}: created #{fact[:created]} by #{fact[:by]}, requested #{fact[:requested]} time(s)."
    @msg.say "<#{fact[:action]}> #{fact[:fact]}"
  end

}.description = 'give information about a factoid'

Basil.respond_to(/^(del|rm) ?factoid (\w+)$/) {

  Basil::Storage.with_storage do |store|
    store[:factoids] ||= {}
    store[:factoids].delete(@match_data[2])
  end

  @msg.say 'Ta-da!'

}.description = 'remove a factoid'
