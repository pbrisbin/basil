require 'singleton'
require 'yaml'

module Basil
  # Configuration is lazy-loaded from ./config/basil.yml. You can create
  # one from the provided example. Note: this location may change in the
  # future.
  class Config
    include Singleton

    # delegate to our instance
    def self.method_missing(meth, *args, &block)
      self.instance.send(meth, *args, &block)
    end

    # delegate to our config file
    def method_missing(key)
      yaml[key.to_s] if yaml
    end

    # lazy-load a server object
    def server(*args)
      unless @server
        case server_type
        when :cli  ; @server = Cli.new(*args)
        when :skype; @server = Skype.new(*args)
        else raise 'Invalid or missing server_type. Must be :skype or :cli.'
        end
      end

      @server
    end

    # lazy-load a dispatcher object
    def dispatcher(*args)
      unless @dispatcher
        case dispatcher_type
        when :simple  ; @dispatcher = DispatcherSimple.new(*args)
        when :extended; @dispatcher = DispatcherExtended.new(*args)
        else raise 'Invalid or missing dispatcher_type. Must be :simple or :extended.'
        end
      end

      @dispatcher
    end

    def yaml
      @yaml ||= YAML::load(File.read('config/basil.yml'))
    end

    # We need to temporarily hide the Config object during evaluation
    # plugins since it can access it and see passwords, etc. Through
    # this approach the only thing that can be seen is the location of
    # the config file which I believe is fairly innocuous.
    def self.hide(&block)
      @hidden = true

      return yield
    ensure
      @hidden = false
    end
  end
end
