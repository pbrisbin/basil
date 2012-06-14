module Basil
  module Jenkins
    extend Utils

    def self.on_error(msg = nil, &block)
      yield

    rescue Exception => ex
      $stderr.puts "#{ex}"
      says(msg ? msg : "Sorry, there was some error using the Jenkins API.")
    end

    def self.short_status(job)
      state = if job['color'] =~ /blue/
                "is stable."
              else
                "is FAILING. See #{job['url']} for details."
              end

      " * #{job['name']} #{state}"
    end

    class Api
      include Basil::Utils

      def initialize(path)
        # path must include the trailing slash
        @path = path.gsub(/[^\/]$/, '\&/')
        @json = nil
      end

      def method_missing(method, *args)
        json[method.to_s] if json
      end

      private

      def json
        unless @json
          options = symbolize_keys(Config.jenkins).merge(:path => @path + 'api/json')
          @json = get_json(options)
        end

        @json
      end
    end

    class EmailStrategy
      def initialize(subject_regex, topic_regex)
        @subject_regex = subject_regex
        @topic_regex   = topic_regex
      end

      def create_message(mail)
        subject = mail['Subject']

        return unless subject =~ @subject_regex

        case subject
        when /jenkins build is back to normal : (\w+) #(\d+)/i
          msg = "(dance) #{$1} is back to normal"
        when /build failed in Jenkins: (\w+) #(\d+)/i
          build, job = $1, $2

          extended = get_extended_info(build, job)
          url      = "http://#{Basil::Config.jenkins['host']}/job/#{build}/#{job}/changes"

          msg = [ "(headbang) #{$1} failed!", extended, "Please see #{url}" ].join("\n")
        else
          $stderr.puts "discarding non-matching email (subject: #{subject})"
          return nil
        end

        Basil::Message.new(nil, Basil::Config.me, Basil::Config.me, msg)
      end

      def send_to_chat?(topic)
        topic =~ @topic_regex
      end

      private

      def get_extended_info(build, job)
        if status = Api.new("/job/#{build}/#{job}")
          failCount  = status.actions[4]["failCount"] rescue '?'

          committers = []
          status.changeSet['items'].each do |item|
            committers << item['user']
          end

          "#{failCount} failure(s). Commits made by #{committers.join(", ")}."
        end
      end
    end
  end
end

Basil.check_email(Basil::Jenkins::EmailStrategy.new(/trunk_(unit|functionals|integration)/, /no more broken builds/i))

Basil.respond_to(/^jenkins( (stable|failing))?$/) {

  Basil::Jenkins.on_error do

    status = Basil::Jenkins::Api.new('/')

    case (@match_data[2].strip rescue nil)
    when 'stable'
      title = "Current stable jobs:"
      jobs = status.jobs.select { |job| job['color'] =~ /blue/ }
    when 'failing'
      title = "Current failing jobs:"
      jobs = status.jobs.reject { |job| job['color'] =~ /blue/ }
    else
      title = "Current jobs:"
      jobs = status.jobs
    end

    says(title) do |out|
      jobs.each do |job|
        out << Basil::Jenkins.short_status(job)
      end
    end
  end

}.description = 'interacts with jenkins'

Basil.respond_to(/^jenkins (\w+)/) {

  name = @match_data[1].strip

  Basil::Jenkins.on_error("Can't find info on #{name}") do
    job = Basil::Jenkins::Api.new("/job/#{name}")

    says("#{job.displayName} is #{job.color =~ /blue/ ? "stable" : "FAILING"}") do |out|
      job.healthReport.each do |line|
        out << line['description']
      end

      out << "See #{job.url} for details."
    end
  end

}.description = 'retrieves info on a specific jenkins job'

Basil.respond_to(/^who broke (.+?)\??$/) {

  name = @match_data[1].strip

  Basil::Jenkins.on_error("Can't find info on #{name}") do
    job = Basil::Jenkins::Api.new("/job/#{name}")

    builds = job.builds.map { |b| b['number'].to_i }
    last_stable = job.lastStableBuild['number'].to_i rescue nil

    if last_stable && builds.first == last_stable
      return says "#{job.displayName} is not broken."
    end

    i = 0
    while Basil::Jenkins::Api.new("/job/#{job.name}/#{builds[i]}").building
      i += 1
    end

    test_report = Basil::Jenkins::Api.new("/job/#{job.name}/#{builds[i]}/testReport")

    says do |out|
      test_report.suites.each do |s|
        s['cases'].each do |c|
          if c['status'] != 'PASSED'
            next if c['name'] =~ /marked_as_flapping/

            name  = "#{c['className']}##{c['name']}"
            since = c['failedSince']

            out << "#{name} first broke in #{since}"

            begin
              breaker = Basil::Jenkins::Api.new("/job/#{job.name}/#{since}")

              breaker.changeSet['items'].each do |item|
                out << "    * r#{item['revision']} [#{item['user']}] - #{item['msg']}"
              end
            rescue
              out << "    ! no info on that build"
            end

            out << ""
          end
        end
      end
    end
  end

}.description = 'tells you what commits lead to the first broken build'
