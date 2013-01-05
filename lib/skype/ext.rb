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

    if chats.nil? || rand(100) < 5
      # 5% of the time, we freshen our chats list
      send_raw_command('SEARCH CHATS')
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
    listeners[event] << block
  end

  def on_chatmessage_received(&block)
    on(:chatmessage) do |args|
      id, _, status = args.split(' ')
      yield(id) if status && status == 'RECEIVED'
    end
  end

  def setup_chats_handler
    on(:chats) { |args| self.chats = args.split(', ') }
  end

  def debug=(value)
    self.class.DEBUG = value
  end

  def chats
    mutex.synchronize { @chats }
  end

  def chats=(chats)
    mutex.synchronize { @chats = chats }
  end

  private

  def listeners
    @listeners ||= Hash.new { |h,k| h[k] = [] }
  end

  def mutex
    @mutex ||= Mutex.new
  end

end
