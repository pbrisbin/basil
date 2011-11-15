module Basil
  # Configuration is lazy-loaded from ./config/basil.yml. You can create
  # one from the provided example. Note: this location may change in the
  # future.
  class Config
    include Basil

    @@yaml        = nil
    @@hidden      = false
    @@config_file = './config/basil.yml'

    def self.method_missing(key)
      if yaml.has_key?(key.to_s)
        yaml[key.to_s]
      else
        # requesters of optional configuration values should be prepared
        # to rescue this at the site of use.
        raise "configuration key #{key} not found."
      end
    end

    def self.server
      case server_type
      when :cli  ; @@server ||= Server::Cli.new
      when :skype; @@server ||= Server::SkypeBot.new
      when :test ; @@server ||= Server::Mock.new
      else raise 'Invalid or missing server_type. Must be :skype or :cli.'
      end
    end

    def self.config_file
      @@config_file
    end

    def self.config_file=(file)
      @@config_file = file
    end

    def self.yaml
      return {} if @@hidden

      unless @@yaml
        require 'yaml'

        fh = File.open(config_file)
        @@yaml = YAML::load(fh)
      end

      @@yaml
    ensure
      fh.close if fh
    end

    # We need to temporarily hide the Config object during evaluation
    # plugins since it can access it and see passwords, etc. Through
    # this approach the only thing that can be seen is the location of
    # the config file which I believe is fairly innocuous.
    def self.hide
      @@hidden = true

      return yield
    ensure
      @@hidden = false
    end
  end
end
