module Basil
  class Plugin
    def self.count_loaded
      responders.length + watchers.length + email_checkers.length
    end

    def self.clear_loaded!
      responders.clear
      watchers.clear
      email_checkers.clear
    end
  end
end

Basil.respond_to('reload') {

  a = Basil::Plugin.count_loaded

  Basil::Plugin.clear_loaded!

  b = Basil::Plugin.count_loaded

  Basil::Plugin.load!

  c = Basil::Plugin.count_loaded

  @msg.say "#{a - b} plugins removed, #{c - b} plugins (re)loaded."

}.description = 'reloads all plugins'
