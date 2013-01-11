Basil.respond_to('restart') {

  begin
    system('./bin/basil-service restart &')
    @msg.say 'restarting...'
  rescue
  end

}.description = 'restarts basil entirely'
