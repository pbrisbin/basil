# Basil

*pronounced BAH-zil*

A skype bot who hopes to be as cool as phrik and as useful as hubot.

![Basil Test](http://pbrisbin.com/static/fileshare/basil_test.png)

## Why skype, and not IRC?

We use skype at work the way I've always used IRC for FOSS projects. 
It's a place for support, meetings, fire-drills, and just hanging out.

I've always wanted phrik (#archlinux's bot) there, he's so useful -- So 
I got the idea to try and write Basil.

It started as a simple command line REPL which aimed to make life as 
easy as possible for potential plugin writers.

After seeing that my fantasy of skype integration was actually possible 
and not all that hard, I've tweaked the design to cater to that 
use-case.

Shockingly, it works.

That said, things are modular -- if you write `Basil::Server::Irc#run` 
you're all set.

## Why not fork hubot?

* I wanted it to be in ruby

This way, all my coworkers can tinker with him too. It also made the 
skype integration easy by way of nfelger's gem.

* It's not a very big wheel to reinvent

The heart of basil is tiny (~150 sloc). This is not including the skype 
server and plugins which would've been written for a hubot fork anyway.

* Hubot's not that special

He's great, amazing, popular -- but he's not the first chat bot to be 
written or the only one in wide-use today.

Besides, I found this project interesting and fun to do from scratch.

Hubot scripts and basil plugins share a similar structure 
(unintentional, I swear) so porting one to the other is much simpler 
than you'd expect.

## Installation

*requires ruby 1.9 and the Skype setup is linux-only*

    git clone https://github.com/pbrisbin/basil
    cd basil
    rake install
    cp ./config/example.yml ./config/basil.yml
    vim basil.yml

*Note: Basil will look for `./config/basil.yml` and `./plugins/*.rb` so 
you must run him from the project root -- this should change soon*

### Cli

1. Execute `basil`
2. Type messages

### Skype

1. Install skype
2. Setup a profile for your bot to run as
3. Start skype
5. Execute `basil`
6. Prefix messages with `basil, ` or `! ` (or `> ` for code evaluation)

## Development Usage

    bundle install
    bundle exec ruby -Ilib ./bin/basil

## Extending

The whole goal is to write plugins that do useful things. Check out 
`./plugins` for his current set. The pattern should be fairly obvious.

Here's a silly one as an example:

~~~ { .ruby }
#
# basil, call me a taxi
# => fine, you're a taxi.
#
Basil::Plugin.respond_to(/^call me a (.*)$/) {

  replies "fine, you're a #{@match_data[1]}."

}.description = 'replies sarcastically'
~~~

Your block is defined as a singleton method on an instance of `Plugin` 
so you can create/access your own instance variables and call all the 
provided helper methods (hint: you can even re`dispatch`).

Here's hoping this grows into something useful...
