class Skype
  # Add a way for us to define a custom CommandManager
  attr_writer :command_manager

  # Leverages the common structure of GET API calls to DRY up property
  # access.
  #
  #   get("THING IDENTIFIER PROPERTY")
  #   # -> GET THING IDENTIFIER PROPERTY
  #   # <- THING IDENTIFIER PROPERTY value
  #   # => "value"
  #
  def get(property)
    response = send_raw_command("GET #{property}")
    response[property.length..-1].strip
  end

  # Sends the message to the named chat
  def message_chat(name, message)
    send_raw_command("CHATMESSAGE #{name} #{message}")
  end

  # Behaves just like CommandManager but rather than look for handling
  # methods on self, sends the messages to delegate for handling.
  class Delegator < CommandManager
    def initialize(skype, delegate)
      super(skype)

      @delegate = delegate
    end

    # also fixes a bug in handling empty events
    def process_command(command)
      command, args = command.split(/\s+/, 2)
      command = command.downcase.to_sym rescue nil

      if command && @delegate.public_methods.include?(command)
        @delegate.send(command, args)
      end
    end
  end
end
