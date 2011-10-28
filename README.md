# Basil

A module bot design with three components:

### Server

A basil server is implemented by subclassing `Basil::Server` and 
defining two methods: `listen` and `puts`.

`listen` should block while waiting for a message through its 
implementation-specific channels and translate any messages into an 
instance of `Basil::Message` which is returns.

`puts` should be how your server outputs text. Basil will wait for 
`listen` to return, process the `Message` through its `Plugins` and if a 
reply is triggered it is passed directly to `puts`.

### Client

A basil client is a translation layer. It should shuttle messages from 
something (think, irc channel) to your server. This layer is not always 
needed. As an example the `CliServer` interfaces directly with the user 
via a prompt so no client is needed.

### Plugins

A basil plugin looks at a message and possible acts on it, often 
providing a reply. A plugin is created by subclassing `Basil::Plugin` 
and defining two methods: `match` and `reply`.

`match` will be given a `Basil::Message` and should return `true` if the 
plugin wishes to act on that message. In that case, `reply` will be 
called and the text returned sent directly to `Basill::Server.puts`.

Note that `match` is the only point your plugin actually sees the 
message, so if you wish to use any of it's text in your reply, store it 
in a class variable during the check (see `./plugin/echo.rb` for an 
example).

Basil as is stands is not feature-rich. I've been hacking on it for all 
of about 45 minutes. However, the premise has been proven -- I have a 
`CliServer` which I can interact with and two plugins that work.

The goal at this point is to write other `Basil::Server`s and 
`Basil::Plugin`s. I think I've made it easy.

Expect more documentation to come as this project matures.

### Installation

1. install the `jeweler` gem
2. clone this repo
3. rake install
4. `basil`

As things get more complex, `lib/basil/config.rb` should come into play 
but for right now there's just the `CliServer`.
