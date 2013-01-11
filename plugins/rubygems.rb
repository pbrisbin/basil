# port of https://github.com/github/hubot-scripts/blob/master/src/scripts/rubygems.coffee
Basil.respond_to(/^gem search (.+)/i) {

  gems = get_json("http://rubygems.org/api/v1/search.json?query=#{escape(@match_data[1])}")[0..4] rescue []

  if gems.empty?
    @msg.say "no results found."
  else
    gems.each do |gem|
      @msg.say "#{gem['name']}: https://rubygems.org/gems/#{gem['name']}"
    end
  end

}.description = "searches rubygems.org"
