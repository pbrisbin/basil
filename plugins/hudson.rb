module Basil
  class Plugin
    def hudson_config
      @config ||= { :url      => 'hudson1.ideeli.com',
                    :port     => 8080,
                    :username => 'X',
                    :password => 'X' }
    end

    def get_hudson_api(path)
      config = hudson_config

      # Note: path must have a trailing slash
      get_json(config[:url], path + 'api/json',
               config[:port], config[:username],
               config[:password])
    end
  end

  class HudsonJob
    attr_reader :name, :url, :builds

    def initialize(json)
      @name   = json['name']
      @url    = json['url']
      @stable = json['color'] =~ /^blue/
      @builds = json['builds'].map {|b| HudsonBuild.new(b) } rescue []
      @long_description = json['healthReport'].map { |d| d['description'] }.join("\n") rescue ''
    end

    def stable?
      @stable
    end

    def short_description
      if stable?
        "#{@name} is stable"
      else
        "#{@name} is FAILING => #{@url}"
      end
    end

    def long_description
      if stable?
        short_description
      else
        [short_description, @long_description].join("\n")
      end
    end
  end

  # TODO:
  class HudsonBuild
    attr_reader :number, :url

    def initialize(json)
    end

    def passed?
    end
  end
end

Basil::Plugin.respond_to('hudson') {

  out = []

  json = get_hudson_api('/')
  json['jobs'].each do |job|
    hudson_job = Basil::HudsonJob.new(job)
    out << hudson_job.short_description
  end

  says out.join("\n") unless out.empty?

}.description = 'gives current hudson status'

Basil::Plugin.respond_to(/^hudson (.*)/) {

  job = @match_data[1].strip rescue ''
  json = get_hudson_api("/job/#{job}/")
  hudson_job = Basil::HudsonJob.new(json)

  says hudson_job.long_description

}.description = 'gives current hudson build status'
