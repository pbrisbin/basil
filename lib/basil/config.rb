require 'yaml'

module Basil
  module Config
    class << self

      def method_missing(key, *)
        yaml[key.to_s] if yaml
      end

      attr_writer :server

      def server
        @server ||=
          Basil.const_get("#{server_type}".capitalize).tap do |k|
            # ensure we only instantiate Servers
            raise NameError unless k < Server
          end.new
      rescue NameError
        raise ArgumentError, "Invalid server type: #{server_type}"
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

      private

      def yaml
        return {} if @hidden

        @yaml ||= YAML::load(File.read('config/basil.yml'))
      end

    end
  end
end
