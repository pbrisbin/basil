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

This way, all my coworkers can tinker with him too.

* It's not a very big wheel to reinvent

The heart of basil is tiny (~150 sloc). The bulk of the project is the 
skype server and plugins -- both of which would need to be written from 
scratch anyway.

* Aside from the github-workflow-specific plugins, hubot doesn't have 
  much

All the my-workflow-specific plugins would need to be written *somewhere* 
anyway. And writing plugins is so easy (I hope) that reproducing 
anything hubot offers shouldn't be difficult.

All this combined with the fact that I found this project interesting 
and fun to do from scratch and, well, there you go.

## Installation

*requires ruby 1.9 and the Skype setup is linux-only*

1. Clone the repo and adjust `lib/basil/config.rb` to specify the type 
   of server you want to use
2. Continue with server-specific instructions

### Cli

1. Start `basil`
2. Type messages

### Skype

1. Install skype
2. Setup a profile for your bot to run as
3. Start skype
4. Install and verify that nfelger's [skype gem][] is working
5. Start `basil`
6. Prefix messages with `basil, ` or `! `

[skype gem]: https://github.com/nfelger/skype

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
so you can access all its instance variables and helper methods.

Here's hoping this grows into something useful...
