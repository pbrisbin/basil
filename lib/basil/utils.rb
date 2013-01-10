module Basil
  # Utility functions that are useful across multiple plugins should
  # reside here. They are mixed into the Plugin class. Functions here,
  # and plugins in general, should avoid rescuing errors -- let them
  # bubble up to be handled appropriately by the dispatcher.
  module Utils
    # Accesses chat history
    def chat_history(options = {})
      chat = options.delete(:chat)

      ChatHistory.get_messages(chat || @msg.chat, options)
    end

    # Purges chat history
    def purge_history!(chat = @msg.chat)
      ChatHistory.clear(chat)
    end

    #
    # Handles both single and multi-line statements to no one in
    # particular.
    #
    #   says "something"
    #
    #   says do |out|
    #     out << "first line"
    #     out << "second line"
    #   end
    #
    # The two invocation styles can be combined to do a sort of Header
    # and Lines thing when printing tabular data; the first argument
    # will be the first line printed then the rest will be built from
    # your block.
    #
    #   says "here's some data:" do |out|
    #     data.each do |d|
    #       out << d.to_s
    #     end
    #   end
    #
    def says(txt = nil, &block)
      if block_given?
        out = txt.nil? ? [] : [txt]

        yield out

        return says(out.join("\n")) unless out.empty?
      elsif txt
        return Message.new(:from => Config.me, :text => txt, :chat => @msg.chat)
      end

      nil
    end

    # Same usage and behavior as says but this will direct the message
    # back to the person who sent the triggering message.
    def replies(txt = nil, &block)
      if block_given?
        out = txt.nil? ? [] : [txt]

        yield out

        return replies(out.join("\n")) unless out.empty?
      elsif txt
        return Message.new(:to => @msg.from_name, :from => Config.me, :text => txt, :chat => @msg.chat)
      end

      nil
    end

    def forwards_to(new_to)
      Message.from_message(@msg, :to => new_to, :from => Config.me, :from_name => Config.me)
    end

    # Set the chat attribute of the underlying message. This allows
    # broadcasters to define what chat they're broadcasting to.
    # Eventually, maybe we'll allow cross-chat communication via basil.
    def set_chat(chat)
      @msg.chat = chat if @msg
    end

    def escape(str)
      require 'cgi'
      CGI::escape(str.strip)
    end

    def get_http(options)
      HTTP.get(options)
    end

    # Pass-through to get_http but yields to the block for conversion
    # (see get_json, xml or html for uses).
    def parse_http(*args, &block)
      resp = get_http(*args)
      yield resp.body if resp
    end

    def get_json(*args)
      require 'json'
      parse_http(*args) { |b| JSON.parse(b) }
    end

    def get_xml(*args)
      require 'faster_xml_simple'
      parse_http(*args) { |b| FasterXmlSimple.xml_in(b) }
    end

    def get_html(*args)
      require 'nokogiri'
      parse_http(*args) { |b| Nokogiri::HTML.parse(b) }
    end
  end
end
