require 'yaml'

module Basil
  module Config
    DEFAULTS = {
      'me'                => 'basil',
      'server_class'      => Skype,
      'plugins_directory' => File.join(Dir.pwd, 'plugins'),
      'pstore_file'       => File.join(Dir.pwd, 'basil.pstore'),
      'config_file'       => File.join(Dir.pwd, 'config', 'basil.yml'),
      'lock_file'         => File.join('', 'tmp', 'basil.lock'),
      'log_file'          => File.join('tmp', 'basil.log'),
      'pid_file'          => File.join('tmp', 'basil.pid'),
      'email'             => {},
      'extras'            => {}
    }

    class << self
      attr_writer(*DEFAULTS.keys)

      def method_missing(key, *)
        attribute(key) || extras["#{key}"]
      end

      def load!
        if config_file && File.exists?(config_file)
          set_attributes(YAML::load(File.read(config_file)))
        end
      rescue => ex
        Basil.logger.warn "Error loading #{config_file}:"
        Basil.logger.warn ex
      end

      attr_writer :server

      def server
        @server ||= server_class.new
      end

      attr_writer :background

      def background?
        @background && !cli?
      end

      def foreground?
        !background?
      end

      def check_email?
        !( cli? || email.empty? )
      end

      def cli?
        server.is_a?(Cli)
      end

      def hide(&block)
        current = extras
        self.extras = {}

        yield

      ensure
        self.extras = current
      end

      private

      def set_attributes(hsh)
        DEFAULTS.keys.each do |key|
          if hsh.has_key?(key)
            value = hsh.delete(key)
            send("#{key}=", value)
          end
        end

        # leftovers go into #extra
        self.extras = hsh
      end

      def attribute(key)
        ivar = :"@#{key}"

        if instance_variables.include?(ivar)
          instance_variable_get(ivar)
        else
          DEFAULTS["#{key}"]
        end
      end

    end
  end
end
