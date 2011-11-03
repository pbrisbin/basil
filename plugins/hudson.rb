module Basil
  class Plugin
    def get_hudson_api(path)
      # Note: path must have a trailing slash
      get_json(Config.hudson_host, path + 'api/json',
               Config.hudson_port,
               Config.hudson_user,
               Config.hudson_password)
    end
  end

  module Hudson
    class Job
      attr_reader :name, :url, :builds

      def initialize(json)
        @name   = json['name']
        @url    = json['url']
        @stable = json['color'] =~ /^blue/

        # present in per-job json
        @builds = json['builds'].map { |b| HudsonBuild.new(b) } rescue []
        @health = json['healthReport'].map { |d| d['description'] } rescue []
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
          ([short_description] + @health).join("\n")
        end
      end
    end

    class Build
      attr_reader :number, :url

      def initialize(json)
        @number = json['number']
        @url    = json['url']
      end
    end
  end
end

Basil::Plugin.respond_to('hudson') {

  json = get_hudson_api('/')
  out  = json['jobs'].map do |job|
    hudson_job = Basil::Hudson::Job.new(job)
    hudson_job.short_description
  end

  says out.join("\n") unless out.empty?

}.description = 'gives current hudson status'

Basil::Plugin.respond_to(/^hudson (.+)/) {

  job  = @match_data[1].strip
  json = get_hudson_api("/job/#{job}/")
  hudson_job = Basil::Hudson::Job.new(json)

  says hudson_job.long_description

}.description = 'gives current hudson build status'
