Basil.respond_to('restart') {

  begin
    system('./bin/basil-service restart &')
    says 'restarting...'
  rescue
  end

}.description = 'restarts basil entirely'
