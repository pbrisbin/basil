require 'basil/version'

Basil.respond_to('version')      { says Basil::VERSION }
Basil.respond_to('ruby version') { says RUBY_VERSION   }
