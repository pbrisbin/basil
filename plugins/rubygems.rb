# port of https://github.com/github/hubot-scripts/blob/master/src/scripts/rubygems.coffee
Basil.respond_to(/^gem search (.+)/i) {

  gems = get_json("http://rubygems.org/api/v1/search.json?query=#{escape(@match_data[1])}")[0..4]

  if gems && gems.any?
    gems.each do |gem|
      @msg.say "#{gem['name']}: https://rubygems.org/gems/#{gem['name']}"
    end
  else
    @msg.say "no results found."
  end

}.description = "searches rubygems.org"
