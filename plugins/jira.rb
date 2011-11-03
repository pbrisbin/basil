module Basil
  class Plugin
    def jira_config
      @config ||= { :host     => Config.jira_host,
                    :port     => Config.jira_port,
                    :username => Config.jira_user,
                    :password => Config.jira_password }
    end

    def get_jira_json(path)
      config = jira_config

      get_json(config[:host], path,
               config[:port], config[:username],
               config[:password], true)
    end
  end

  module Jira
    class Ticket
      attr_reader :url, :title

      def initialize(key, json)
        @key   = key
        @title = json['fields']['summary']['value'] rescue nil
        @url   = "https://#{Basil::Config.jira_host}/browse/#{@key}"
      end
    end
  end
end

Basil::Plugin.watch_for(/core-\d+/i) {

  begin
    key = @match_data[0].upcase
    json = get_jira_json("/rest/api/2.0.alpha1/issue/#{key}")
    ticket = Basil::Jira::Ticket.new(key, json)

    # title is parsed, url is built
    says "#{ticket.url} : #{ticket.title}" if ticket.title
  rescue => e
    $stderr.puts e.message
    nil
  end

}
