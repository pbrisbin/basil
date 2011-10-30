require 'basil/plugins'
require 'basil/config'
require 'basil/servers/cli'
require 'basil/servers/skype'

module Basil
  def self.run
    Plugin.load!
    server = Config.server
    server.run
  end

  class Message
    include Basil

    attr_reader :to, :from, :time, :text

    def initialize(to, from, text)
      @time = Time.now
      @to, @from, @text = to, from, text
    end

    def to_me?
      to == Config.me
    end
  end
end
