module Basil
  class Plugin
    def self.count_loaded
      responders.length + watchers.length + email_strategies.length
    end

    def self.clear_loaded!
      responders.delete_if       { true }
      watchers.delete_if         { true }
      email_strategies.delete_if { true }
    end
  end
end

Basil.respond_to('reload') {

  a = Basil::Plugin.count_loaded

  Basil::Plugin.clear_loaded!

  b = Basil::Plugin.count_loaded

  Basil::Plugin.load!

  c = Basil::Plugin.count_loaded

  says "#{a - b} plugins removed, #{c - b} plugins (re)loaded."

}.description = 'reloads all plugins'
