require 'yaml'

module Basil
  class Config
    private_class_method :new

    class << self
      def method_missing(key, *_)
        yaml[key.to_s] if yaml
      end

      attr_writer :server

      def server
        @server ||= begin
          server_class = Basil.const_get("#{server_type}".capitalize)
          server_class.new
        end
      rescue NameError
        raise ArgumentError, "Invalid server_type: #{server_type}"
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
end
