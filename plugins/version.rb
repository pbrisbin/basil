require 'basil/version'

Basil::Plugin.respond_to('version')      { says Basil::VERSION }
Basil::Plugin.respond_to('ruby version') { says RUBY_VERSION   }
