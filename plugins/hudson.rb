module Basil
  class HudsonApi
    include Utils

    # Note: path must include the trailing slash
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
        @json = get_json(Basil::Config.hudson_host, @path + 'api/json',
                         Basil::Config.hudson_port,
                         Basil::Config.hudson_user,
                         Basil::Config.hudson_password)
      end

      @json
    end
  end
end

Basil::Plugin.respond_to(/^hudson( (stable|failing))?$/) {

  begin
    status_line = lambda do |job|
      " * #{job['name']} #{job['color'] =~ /blue/ ? "is stable." : "is FAILING. See #{job['url']} for details."}"
    end

    status = Basil::HudsonApi.new('/')

    says_multiline do |out|
      case (@match_data[2].strip rescue nil)
      when 'stable'
        out << "Current stable jobs:"
        status.jobs.select { |job| job['color'] =~ /blue/ }.each { |job| out << status_line.call(job) }
      when 'failing'
        out << "Current failing jobs:"
        status.jobs.reject { |job| job['color'] =~ /blue/ }.each { |job| out << status_line.call(job) }
      else
        out << "Current jobs:"
        status.jobs.each { |job| out << status_line.call(job) }
      end
    end
  rescue
    says "There was an issue talking to hudson."
  end

}.description = 'interacts with hudson'

Basil::Plugin.respond_to(/^hudson (\w+)/) {

  begin
    job = Basil::HudsonApi.new("/job/#{@match_data[1].strip}/")

    says_multiline("#{job.displayName} is #{job.color =~ /blue/ ? "stable" : "FAILING"}") do |out|
      job.healthReport.each do |line|
        out << line['description']
      end

      out << "See #{job.url} for details."
    end
  rescue
    says "Can't find info on #{@match_data[1]}"
  end

}.description = 'retrieves info on a specific hudson job'

Basil::Plugin.respond_to(/who broke (\w+)/) {

  begin
    job = Basil::HudsonApi.new("/job/#{@match_data[1].strip}/")

    builds = job.builds.map { |b| b['number'].to_i }
    last_stable = job.lastStableBuild['number'].to_i rescue nil

    if last_stable && builds.first == last_stable
      return says "#{job.displayName} is not broken."
    end
      
    i = 0
    while Basil::HudsonApi.new("/job/#{job.name}/#{builds[i]}/").building
      i += 1
    end

    test_report = Basil::HudsonApi.new("/job/#{job.name}/#{builds[i]}/testReport/")

    says_multiline do |out|
      test_report.suites.each do |s|
        s['cases'].each do |c|
          if c['status'] == 'FAILED'
            next if c['name'] =~ /marked_as_flapping/

            name  = "#{c['className']}##{c['name']}"
            since = c['failedSince']

            out << "#{name} first broke in #{since}"

            breaker = Basil::HudsonApi.new("/job/#{job.name}/#{since}/")

            breaker.changeSet['items'].each do |item|
              out << "    * r#{item['revision']} [#{item['user']}] - #{item['msg']}"
            end

            out << ""
          end
        end
      end
    end
  rescue => e
    $stderr.puts e.message

    says "Can't find info on #{@match_data[1]}"
  end

}.description = 'tells you what commits lead to the first broken build'
