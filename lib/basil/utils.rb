module Basil
  module Utils
    # Simply returns the +chat+ attribute for the Message currently
    # being handled.
    def chat
      @msg.chat
    end

    # Accesses chat history
    def chat_history(options = {})
      chat = options.delete(:chat)

      ChatHistory.get_messages(chat || self.chat, options)
    end

    # Purges chat history
    def purge_history!(chat = self.chat)
      ChatHistory.clear(chat)
    end

    def trim(str)
      str.lines.map(&:strip).join("\n")
    end

    def escape(str)
      require 'cgi'
      CGI::escape("#{str}".strip)
    end

    # See Basil::HTTP.get
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
