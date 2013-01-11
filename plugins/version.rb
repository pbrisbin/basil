Basil.respond_to('version')      { @msg.say Basil::VERSION }
Basil.respond_to('ruby version') { @msg.say RUBY_VERSION   }
