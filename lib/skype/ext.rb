class Skype
  #
  # Overrides
  #
  def received_command(command_str)
    cmd, args = command_str.split(/\s+/, 2)

    return unless cmd

    listeners[cmd.downcase.to_sym].each do |block|
      block.call(args)
    end
  end

  #
  # Extensions
  #
  def get(property)
    response = send_raw_command("GET #{property}")
    response[property.length..-1].strip
  end

  def message_chat(name, message)
    send_raw_command("CHATMESSAGE #{name} #{message}")
  end

  def on(event, &block)
    listeners[event] << block if block
  end

  def on_chatmessage_received(&block)
    on(:chatmessage) do |args|
      id, _, status = args.split(' ')
      yield(id) if status && status == 'RECEIVED'
    end
  end

  private

  def listeners
    @listeners ||= Hash.new { |h,k| h[k] = [] }
  end

end
