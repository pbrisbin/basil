# port of https://github.com/github/hubot-scripts/blob/master/src/scripts/rubygems.coffee
Basil::Plugin.respond_to(/^there's a gem for (.+)/i) {

  gems = get_json("http://rubygems.org/api/v1/search.json?query=#{escape(@match_data[1])}")[0..4] rescue []

  if gems.empty?
    says "Actually, there isn't a gem for that!"
  else
    says do |out|
      gems.each do |gem|
        out << "#{gem['name']}: https://rubygems.org/gems/#{gem['name']}"
      end
    end
  end

}.description = "searches rubygems.org"
