module Basil
  class Airbrake
    include Utils

    def self.pretty_print(group, msg)
      most_recent_at = group["most-recent-notice-at"]["__content__"]
      notices_count  = group["notices-count"]["__content__"]
      error_id       = group["id"]["__content__"]
      error_message  = group["error-message"]
      error_class    = group["error-class"]

      error_url = "https://#{Config.airbrake['account']}.airbrakeapp.com/errors/#{error_id}"

      msg.say ""
      msg.say " ##{error_id}(#{notices_count}) last seen:#{most_recent_at}"
      msg.say " #{error_class}: #{error_message}"
      msg.say " => #{error_url}"
    end

    def initialize
      @host = [Config.airbrake['account'], 'airbrake', 'io'].join('.')

      # we assume we only care about one environment and it's specified
      # in the config file as project.
      project = Config.airbrake['project'].to_s

      if project and !project.empty?
        @path = "/projects/#{project}/errors.xml?auth_token=#{Config.airbrake['token']}"
      else
        @path = "/errors.xml?auth_token=#{Config.airbrake['token']}"
      end
    end

    def method_missing(meth, *args)
      return xml[meth.to_s] if xml
    end

    def xml
      @xml ||= get_xml('host' => @host, 'port' => 443, 'path' => @path)
    end
  end
end

Basil.respond_to(/^(show me )?airbrake( errors)?/i) {

  xml = Basil::Airbrake.new

  @msg.reply "5 most recent airbrake errors:"

  xml.groups["group"][0..5].each do |group|
    Basil::Airbrake.pretty_print(group, @msg)
  end

}.description = "shows the five most recent airbrake errors in production."
