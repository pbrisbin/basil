require 'basil/utils'
require 'basil/plugins'
require 'basil/config'
require 'basil/broadcast'
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

    attr_reader :to, :from, :from_name, :time, :text

    def initialize(to, from, from_name, text)
      @time = Time.now
      @to, @from, @from_name, @text = to, from, from_name, text
    end

    def to_me?
      to == Config.me
    end
  end
end
