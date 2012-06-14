module Basil
  module Jenkins
    extend Utils

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
      end

      def method_missing(method, *args)
        json[method.to_s] if json
      end

      def passing?
        color =~ /blue/
      end

      private

      def json
        @json ||= get_json(Config.jenkins.merge(
          'path' => @path + 'api/json'))
      end
    end

    class EmailStrategy
      SUBJECT_REGEX = /trunk_(unit|functionals|integration)/
      CHAT_TITLE    = 'Dev/Arch + No more broken builds'

      def self.create_message(mail)
        subject = mail['Subject']

        return unless subject =~ SUBJECT_REGEX

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

        Basil::Message.new(nil, Basil::Config.me, Basil::Config.me, msg, CHAT_TITLE)
      end

      def self.get_extended_info(build, job)
        if status = Api.new("/job/#{build}/#{job}")
          failCount  = status.actions[4]["failCount"] rescue '?'

          committers = []
          status.changeSet['items'].each do |item|
            committers << item['user']
          end

          "#{failCount || '?'} failure(s). Commits made by #{committers.uniq.join(", ")}."
        end
      end
    end
  end
end

Basil.check_email(Basil::Jenkins::EmailStrategy)

Basil.respond_to(/^jenkins$/) {

  says("build status") do |out|
    Basil::Jenkins::Api.new('/').jobs.each do |job|
      out << Basil::Jenkins.short_status(job)
    end
  end

}.description = 'interacts with jenkins'

Basil.respond_to(/^jenkins (\w+)/) {

  job = Basil::Jenkins::Api.new("/job/#{@match_data[1].strip}")

  says do |out|
    out << "#{job.displayName} is #{job.passing? ? "stable" : "FAILING"}"

    job.healthReport.each do |line|
      out << line['description']
    end

    out << "See #{job.url} for details."
  end

}.description = 'retrieves info on a specific jenkins job'

Basil.respond_to(/^who broke (.+?)\??$/) {

  job = Basil::Jenkins::Api.new("/job/#{@match_data[1].strip}")

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

}.description = 'tells you what commits lead to the first broken build'
