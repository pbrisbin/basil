# https://github.com/github/hubot-scripts/blob/master/src/scripts/commitmessage.coffee
Basil.respond_to(/commit ?message/i) {

  @msg.say get_http("http://whatthecommit.com/index.txt").body

}.description = "give a random commit message"
