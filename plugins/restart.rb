Basil.respond_to('restart') {

  begin
    system('bundle exec ./bin/basil restart &')
    @msg.say 'restarting...'
  rescue
  end

}.description = 'restarts basil entirely'
