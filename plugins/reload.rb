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

  prev = Basil::Plugin.count_loaded

  Basil::Plugin.clear_loaded!
  Basil::Plugin.load!

  cur = Basil::Plugin.count_loaded

  @msg.say "#{prev} plugins removed, #{cur} plugins (re)loaded."

}.description = 'reloads all plugins'
