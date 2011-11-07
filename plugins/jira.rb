module Basil
  class Plugin
    def get_jira_json(path)
      get_json(Config.jira_host, path,
               Config.jira_port,
               Config.jira_user,
               Config.jira_password, true)
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

Basil::Plugin.watch_for(/\w+-\d+/i) {

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
