# Basil - */'ba-zəl/*

A skype bot hoping to be as cool as phrik and as [useful][] as hubot.

[useful]: http://en.wikipedia.org/wiki/Basil_Exposition#Basil_Exposition

![Basil Test](http://pbrisbin.com/static/fileshare/basil_test.png)

## Why skype, and not IRC?

We use skype at work the way I've always used IRC for FOSS projects. 
It's a place for support, meetings, fire-drills, and just hanging out.

For any bot to be useful for us, he would have to live there.

## Why not fork hubot?

* I wanted it to be in ruby

This way, all my coworkers can tinker with him too. It also made the 
skype integration easy by way of nfelger's gem.

* It's not a very big wheel to reinvent

The heart of basil is tiny. This is not including the skype server and 
plugins which would've been written for a hubot fork anyway.

* Hubot's not that special

He's great, amazing, popular -- but he's not the first chat bot to be 
written or the only one in wide-use today.

Besides, I found this project interesting and fun to do from scratch.

## Usage

Since basil relies on a skype gem only available on github, current 
usage relies on bundler and running from source.

~~~ { .bash }
git clone https://github.com/pbrisbin/basil && cd basil
cp config/example.yml config/basil.yml # and adjust
bundle install
./bin/basil
~~~

*requires ruby 1.9 and the Skype setup is linux-only*

### Skype

The skype client must be running under a profile to represent the bot. 
Messages to the bot must be prefixed correctly (unless in private chat) 
so he knows to respond.

None of this is required when using `server_type: :cli`.

## Plugins

Writing plugins should be both easy and powerful. Here are some examples 
of the sorts of things plugins can do:

#### Respond to a simple command with a canned reply

~~~ { .ruby }
# works best with 'give'
Basil::Plugin.respond_to('beer') {

  replies "someone wanted you to have this (beer)" # skype emoticon

}
~~~

*Note: the String `'beer'` is interpreted as `/^beer$/` by the 
constructor*

These types of plugins have been removed since they can be implemented 
using the new factoid plugin.

#### Respond cleverly using the trigger's content

~~~ { .ruby }
Basil::Plugin.respond_to(/^call me a (.*)/) {

  says "fine, you're a #{@match_data[1]}."

}
~~~

#### Make a simple web request

~~~ { .ruby }
Basil::Plugin.respond_to(/^g(oogle)? (.*)/) {

  url = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{escape(@match_data[2])}"

  if result = get_json(url)['responseData']['results'].first rescue nil
    replies "#{result['titleNoFormatting']}: #{result['unescapedUrl']}"
  else
    replies "Nothing found."
  end

}.description = 'consults the almighty google'
~~~

*Note: since constructors `return self`, you can easily chain a method 
on the end, like assigning a `description` (which is used by `help`)*

#### Do some not-so-simple web stuff

(The rest of these are longish so I won't reproduce them here.)

[plugins/jira.rb]    (https://github.com/pbrisbin/basil/blob/master/plugins/jira.rb)
[plugins/jenkins.rb] (https://github.com/pbrisbin/basil/blob/master/plugins/jenkins.rb)

#### Persist some data for use in a later response

[plugins/messages.rb] (https://github.com/pbrisbin/basil/blob/master/plugins/messages.rb)
[plugins/karma.rb]    (https://github.com/pbrisbin/basil/blob/master/plugins/karma.rb)

#### Keep and utilize a simple chat history

[plugins/quotedb.rb] (https://github.com/pbrisbin/basil/blob/master/plugins/quotedb.rb)

#### Go meta-basil: introspect and re-dispatch

[plugins/help.rb] (https://github.com/pbrisbin/basil/blob/master/plugins/help.rb)
[plugins/give.rb] (https://github.com/pbrisbin/basil/blob/master/plugins/give.rb)
