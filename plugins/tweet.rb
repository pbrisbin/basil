require 'twitter'

Twitter.configure do |config|
  conf = Basil::Config.twitter

  config.consumer_key       = conf['consumer_key']
  config.consumer_secret    = conf['consumer_secret']
  config.oauth_token        = conf['oauth_token']
  config.oauth_token_secret = conf['oauth_token_secret']
end

Basil.respond_to(/tweet (.+)/) {

  message = @match_data[1]

  if message == 'that'
    if msg = chat_history.first
      message = msg.text
    end
  end

  Twitter.update(message)

  @msg.say "successfully twittereded!"

}.description = 'sends tweets as @basilthebot'
