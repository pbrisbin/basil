module Basil
  class JiraApi
    include Utils

    def initialize(path)
      @path = path
      @json = nil
    end

    def method_missing(method, *args)
      key = method.to_s

      if json.has_key?(key)
        json[key]
      else
        super
      end
    end

    private

    def json
      unless @json
        options = symbolize_keys(Config.jira).merge(:path => '/rest/api/2.0.alpha1' + @path)
        @json = get_json(options)
      end

      @json
    end
  end

  class JiraTicket
    def initialize(key)
      @key  = key.upcase
      @json = nil
    end

    def description
      "#{url} : #{title}"
    end

    def found?
      !title.nil?
    end

    def url
      @url ||= "https://#{Config.jira['host']}/browse/#{@key}"
    end

    def title
      @title ||= json.fields['summary']['value'] rescue nil
    end

    private

    def json
      @json ||= JiraApi.new("/issue/#{@key}")
    end
  end
end

Basil::Plugin.watch_for(/\w+-\d+/i) {

  begin
    ticket = Basil::JiraTicket.new(@match_data[0])
    says ticket.description if ticket.found?
  rescue => e
    $stderr.puts e.message
    nil
  end

}

Basil::Plugin.respond_to(/^find (.+)/i) {

  begin
    jql  = escape('summary ~ "?" OR description ~ "?" OR comment ~ "?"'.gsub('?', @match_data[1].strip))
    json = Basil::JiraApi.new("/search?jql=#{jql}")

    issues = json.issues
    len    = issues.length

    replies('Search results:') do |out|
      issues[0..10].each { |issue|
        ticket = Basil::JiraTicket.new(issue['key'])
        out << ticket.description if ticket.found?
      }

      out << "plus #{len - 10} more..." if len > 10
    end
  rescue => e
    $stderr.puts e.message
    replies "No results found."
  end

}.description = 'find JIRA cards with given search term(s)'
