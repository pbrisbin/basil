class HudsonApi
  HUDSON_URL  = 'hudson1.ideeli.com'
  HUDSON_PORT = 8080

  def self.status
    out  = []
    json = get('')

    return nil unless json

    json['jobs'].each do |job|
      name = job['name']
      ok   = if passed?(job['color'])
               'build is normal'
             else
               'last build FAILED'
             end

      out << "#{name} - #{ok}"
    end

    return out.join("\n")
  end

  def self.job_status(job)
    out = []
    json = get("/job/#{job}")

    return nil unless json

    out << ( passed?(json['color']) ? "Build is stable" : "Last build FAILED" )

    json['healthReport'].each do |report|
      out << report['description']
    end

    return out.join("\n")
  end

  private

  def self.get(path)
    json = nil

    Net::HTTP.start(HUDSON_URL, HUDSON_PORT) do |http|
      req = Net::HTTP::Get.new("#{path}/api/json")
      req.basic_auth username, password
      resp = http.request(req)
      json = JSON.parse(resp.body)
    end

    return json
  rescue
    raise "There was an error talking to hudson"
  end

  def self.username
    @@username ||= '' # TODO: pull from out-of-repo file
  end

  def self.password
    @@password ||= '' # TODO: pull from out-of-repo file
  end

  def self.passed?(color)
    color == 'blue'
  end
end

#
# The actual plugin
#
Basil::Plugin.respond_to(/hudson(.*)/) {

  require 'json'
  require 'net/http'

  job = @match_data[1].strip
  out = if job == ''
          HudsonApi.status
        else
          HudsonApi.job_status(job)
        end

  says out

}.description = 'interacts with hudson builds'
