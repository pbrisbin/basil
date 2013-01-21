class Airbrake
  HOST ||= [Basil::Config.airbrake['account'], 'airbrake', 'io'].join('.')

  class ErrorGroup
    def initialize(group_xml)
      @group = group_xml
    end

    def to_s
      most_recent_at = @group['most-recent-notice-at']['__content__']
      notices_count  = @group['notices-count']['__content__']
      error_id       = @group['id']['__content__']
      error_message  = @group['error-message']
      error_class    = @group['error-class']

      <<-EOS
        ---
        ##{error_id}(#{notices_count}) last seen:#{most_recent_at}
        #{error_class}: #{error_message}
        => https://#{HOST}/errors/#{error_id}
      EOS
    end
  end

  def initialize(plugin)
    # we assume we only care about one environment and it's specified
    # in the config file as project.
    project = "#{Basil::Config.airbrake['project']}"
    token   = "#{Basil::Config.airbrake['token']}"

    path = if project != ''
             "/projects/#{project}/errors.xml?auth_token=#{token}"
           else
             "/errors.xml?auth_token=#{token}"
           end

    @xml = plugin.get_xml('host' => HOST, 'port' => 443, 'path' => path)
  end

  def groups(limit = 5)
    @xml['groups']['group'].take(limit).map do |g|
      ErrorGroup.new(g)
    end
  end
end

Basil.respond_to(/^(show me )?airbrake( errors)?/i) {

  @msg.reply "5 most recent airbrake errors:"

  Airbrake.new(self).groups.each do |g|
    @msg.say trim("#{g}")
  end

}.description = "shows the five most recent airbrake errors in production."
