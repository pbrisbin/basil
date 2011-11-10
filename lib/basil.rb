require 'rubygems'
require 'bundler/setup'

require 'basil/utils'
require 'basil/plugins'
require 'basil/config'
require 'basil/broadcast'
require 'basil/servers/cli'
require 'basil/servers/skype'

module Basil
  # Main program entry point. Loads plugins, instantiates your defined
  # server, and calls its run method which should loop forever.
  def self.run
    Plugin.load!
    server = Config.server
    server.run
  rescue Exception => e
    $stderr.puts e.message
    exit 1
  end

  # The main basil data type: the Message. Servers should construct
  # these and pass them through dispatch which will also return a
  # Message if a response is triggered.
  class Message
    include Basil

    attr_reader :to, :from, :from_name, :time, :text

    def initialize(to, from, from_name, text)
      @time = Time.now
      @to, @from, @from_name, @text = to, from, from_name, text
    end

    # Is this message to my configured nick?
    def to_me?
      to == Config.me
    end
  end
end
