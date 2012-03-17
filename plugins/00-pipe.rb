# This allows commands to be run in a shell-ish pipeline. The first
# command is run and text of its response (if any) is fed as the final
# argument(s) to the next command and so on. The result of the pipeline
# must be a message or the entire thing is ignored.
Basil.respond_to(/\|/) {

  reply    = nil
  commands = @msg.text.split('|').map(&:strip)

  while command = commands.shift
    text  = reply ? "#{command} #{reply.text}" : command
    reply = Basil.dispatch(Basil::Message.new(Basil::Config.me, @msg.from, @msg.from_name, text, @msg.chat))
  end

  reply if reply

}
