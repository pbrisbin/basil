require 'singleton'
require 'yaml'

module Basil
  # Configuration is lazy-loaded from ./config/basil.yml. You can create
  # one from the provided example. Note: this location may change in the
  # future.
  class Config
    include Singleton

    def self.method_missing(meth, *args, &block)
      self.instance.send(meth, *args, &block)
    end

    def method_missing(key)
      yaml[key.to_s] if yaml
    end

    attr_writer :server

    def server
      unless @server
        case server_type
        when :cli  ; @server = Cli.new
        when :skype; @server = Skype.new
        else raise 'Invalid or missing server_type. Must be :skype or :cli.'
        end
      end

      @server
    end

    def yaml
      return {} if @hidden

      @yaml ||= YAML::load(File.read('config/basil.yml'))
    end

    # We need to temporarily hide the Config object during evaluation
    # plugins since it can access it and see passwords, etc.
    def hide(&block)
      @hidden = true

      yield

    ensure
      @hidden = false
    end

    # this is mostly to support testing, but perhaps it should be part
    # of the reload plugin eventually.
    def invalidate
      @yaml = nil
    end
  end
end
