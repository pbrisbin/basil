module Basil
  class Config
    include Basil

    @@yaml   = nil
    @@hidden = false

    def self.method_missing(key)
      if yaml.has_key?(key.to_s)
        yaml[key.to_s]
      else
        $stderr.puts "configuration key #{key} not found."
        nil
      end
    end

    def self.server
      case server_type
      when :skype; @@server ||= Server::SkypeBot.new
      when :cli  ; @@server ||= Server::Cli.new
      else raise "Invalid or missing server_type. Must be :skype or :cli."
      end
    end

    def self.config_file
      './config/basil.yml'
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
      ret = yield
      @@hidden = false

      ret
    end
  end
end
