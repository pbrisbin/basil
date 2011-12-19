require 'basil/utils'
require 'basil/plugins'
require 'basil/config'
require 'basil/broadcast'
require 'basil/storage'
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

  # Basil's dipatch method will take a valid message and ask each
  # registered plugin (responders then watchers) if it wishes to act on
  # it. The first reply received is returned, otherwise nil.
  def self.dispatch(msg)
    return nil unless msg && msg.text != ''

    Plugin.loggers.each { |l| l.triggered(msg) }

    if msg.to_me?
      Plugin.responders.each do |p|
        reply = p.triggered(msg)
        return reply if reply
      end
    end

    Plugin.watchers.each do |p|
      reply = p.triggered(msg)
      return reply if reply
    end

    nil
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
      to.downcase == Config.me.downcase
    rescue
      false
    end
  end
end
