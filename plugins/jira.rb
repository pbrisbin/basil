module Basil
  class JiraApi
    include Utils

    def initialize(path)
      @path = path
    end

    def method_missing(meth, *args)
      json[meth.to_s] if json
    end

    private

    def json
      @json ||= get_json(Config.jira.merge(
        'path' => '/rest/api/2' + @path))
    end
  end

  class JiraTicket
    TIMEOUT ||= 30 * 60 # 30 minutes

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
      @title ||= json.fields['summary'] rescue nil
    end

    private

    def json
      @json ||= JiraApi.new("/issue/#{@key}")
    end
  end
end

Basil.watch_for(/\w+-\d+/) {
  tickets = []

  # people might mention more than one ticket in a message
  found = @msg.text.scan(/\w+-\d+/).uniq

  # don't spam the channel if people mention the same core ticket within
  # a specified timeout period.
  Basil::Storage.with_storage do |store|
    store[:jira_timeouts] ||= {}

    found.each do |id|
      timeout = store[:jira_timeouts][id]

      if !timeout || Time.now > timeout
        tickets << id
        store[:jira_timeouts][id] = Time.now + Basil::JiraTicket::TIMEOUT
      end
    end
  end

  if tickets.any?
    tickets.each do |id|
      ticket = Basil::JiraTicket.new(id)

      if ticket.found?
        url   = ticket.url
        title = ticket.title

        # don't spam information that's already present in the
        # triggering message
        url_present   = @msg.text.include?(url)
        title_present = @msg.text.include?(title)

        unless url_present && title_present
          if url_present
            @msg.say "#{id} : #{title}"
          elsif title_present
            @msg.say "#{url}"
          else
            @msg.say "#{ticket.description}"
          end
        end
      end
    end
  end
}

Basil.respond_to(/^jira search (.+)/i) {

  jql  = escape('summary ~ "?" OR description ~ "?" OR comment ~ "?"'.gsub('?', @match_data[1].strip))
  json = Basil::JiraApi.new("/search?jql=#{jql}")

  if (issues = json.issues) && issues.any?
    @msg.reply 'First 10 results:'

    issues[0..10].each do |issue|
      ticket = Basil::JiraTicket.new(issue['key'])
      @msg.say ticket.description if ticket.found?
    end
  else
    @msg.reply "no results found."
  end

}.description = 'find JIRA cards with given search term(s)'
