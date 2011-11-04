module Basil
  class Config
    include Basil

    @@yaml = nil

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
      unless @@yaml
        require 'yaml'

        fh = File.open(config_file)
        @@yaml = YAML::load(fh)
      end

      @@yaml
    ensure
      fh.close if fh
    end
  end
end
