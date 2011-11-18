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
usage relies on `bundle exec`.

    git clone https://github.com/pbrisbin/basil && cd basil
    cp config/example.yml config/basil.yml # and adjust
    bundle install
    bundle exec ruby -Ilib bin/basil

*requires ruby 1.9 and the Skype setup is linux-only*

### Skype

The skype client must be running under a profile to represent the bot. 
Messages to the bot must be prefixed correctly (even in private chat, 
for now) so he knows to respond.

None of this is required when using `server_type: :cli`.

## Extending

The whole goal is to write plugins that do useful things. Checkout 
existing plugins for an idea of the pattern; it should be fairly 
obvious.

Here's a silly one as an example:

~~~ { .ruby }
#
# basil, call me a taxi
# => fine, you're a taxi.
#
Basil::Plugin.respond_to(/^call me a (.+)/) {

  says "fine, you're a #{@match_data[1]}."

}.description = 'replies sarcastically'
~~~

Your block is defined as a singleton method on an instance of `Plugin` 
so you can create/access your own instance variables and call all the 
provided helper methods (hint: you can even re`dispatch`).

Here's hoping this grows into something useful...
