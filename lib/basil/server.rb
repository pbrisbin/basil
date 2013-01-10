require 'shellwords'

module Basil
  class Server
    # Servers can register commands which will be checked for before
    # normal dispatching. Commands can be sent in chat with the
    # message format "/command [arguments]"
    #
    # If the Server has registered a block to execute for this
    # command, it will be called with the (possibly empty) list of
    # shell split arguments.
    #
    # If it returns a Message, that message is sent and dispatching
    # does not occur. If it returns nil, normal dispatching will
    # proceed.
    def self.has_command(command, &block)
      return unless block_given?
      server_commands[command.to_sym] = block
    end

    def self.server_commands
      @server_commands ||= {}
    end

    # Redefine your start method to be wrapped in a lock file, ensuring
    # no more than one instance of your server can be run at a time.
    def self.lock_start
      alias_method :original_start, :start

      define_method(:start) do
        Lock.guard do
          original_start
        end
      end
    end

    # Loads plugins and kicks off the email checking loop. Subclasses
    # should call super in their start method overrides.
    def start
      Plugin.load!
      Email.check if Config.server.respond_to?(:broadcast_message)

      main_loop
    end

    def main_loop
      raise NotImplementedError, "Server classes must implement #main_loop"
    end

    def dispatch_message(msg)
      unless msg && msg.text != ''
        raise ArgumentError, 'Nil or empty message dispatched'
      end

      ChatHistory.store_message(msg)

      logger.info "Dispatching #{msg}"

      reply = server_command?(msg) || Dispatch.process(msg)

      logger.info "Reply #{msg}" if reply

      reply

    rescue => ex
      logger.warn ex

      nil
    end

    def server_command?(msg)
      if msg.to_me? && msg.text =~ %r{^/(\w+)( (.*))?$}
        command = $1
        args    = $3.shellsplit rescue []

        if block = self.class.server_commands[command.to_sym]
          logger.info "Handling command: #{command}(#{args.join(', ')})"
          return instance_exec(*args, &block)
        end
      end
    end

    private

    def logger
      @logger ||= Loggers['server']
    end
  end
end
