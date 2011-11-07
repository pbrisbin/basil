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

def ticket_url_and_title(key)
  key = key.upcase
  json = get_jira_json("/rest/api/2.0.alpha1/issue/#{key}")
  ticket = Basil::Jira::Ticket.new(key, json)

  # title is parsed, url is built
  "#{ticket.url} : #{ticket.title}" if ticket.title
end

Basil::Plugin.watch_for(/\w+-\d+/i) {

  begin
    s = ticket_url_and_title(@match_data[0])
    says s if s
  rescue => e
    $stderr.puts e.message
    nil
  end

}

Basil::Plugin.respond_to(/^find (.+)/i) {

  begin
    search_terms = @match_data[1]
    search = "summary ~ \"#{search_terms}\" OR description ~ \"#{search_terms}\" OR comment ~ \"#{search_terms}\""

    json = get_jira_json("/rest/api/2.0.alpha1/search?jql=#{escape(search)}")

    replies_multiline('Search results:') do |out|
      issues = json['issues']
      len    = issues.length

      issues[0..10].each { |issue|
        s = ticket_url_and_title(issue['key'])
        out << s if s
      }

      out << "plus #{len - 10} more..." if len > 10
    end
  rescue => e
    $stderr.puts e.message
    replies "No results found."
  end

}.description = 'find JIRA cards with given search term(s)'
