# Basil

A skype bot who hopes to be as cool as phrik or hubot.

![Basil Test](http://pbrisbin.com/static/fileshare/basil_test.png)

## Why?

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

## Installation

For now, it's just hacking so clone the repo and run the binary. You'll 
want to adjust `lib/basil/config.rb` to specify `Server::Cli.new` at 
first since the skype setup is slightly more involved (but not much).

To use `Server::Skype` you'll need to do the following:

1. Install skype
2. Setup a profile for your bot to run as
3. Start skype
4. Install and verify that nfelger's [skype gem][] is working
5. Start basil!

[skype gem]: https://github.com/nfelger/skype

From another skype profile/session you should add basil as a contact and 
IM with him exactly as in the `Cli` server.

## Extending

Extending basil's feature set in a modular way is the ultimate goal. 
There are two components that can be swapped out or added to to change 
basil's behavior: Servers and Plugins.

### Server

`Server::Cli` and `Server::Skype` should be good enough examples of 
what's required. Just define a `run` that does whatever you need.

### Plugins

Plugins should be super simple to write. You can checkout `./plugins` 
for examples. Here's a pretty fun one:

~~~ { .ruby }
Basil::Plugin.respond_to(/^(you are|you're)(.*)$/) {

  replies "no, YOU are#{@match_data[2]}!"

}.description = 'turns it around on you'
~~~

Your block is defined as a method on `Plugin` so you can access all its 
instance variables and methods.

Here's hoping this grows into something useful...
