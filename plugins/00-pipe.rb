# This allows commands to be run in a shell-ish pipeline. The first
# command is run and text of its response (if any) is fed as the final
# argument(s) to the next command and so on. The result of the pipeline
# must be a message or the entire thing is ignored.
Basil.respond_to(/\|/) {

  reply    = nil
  commands = @msg.text.split('|').map(&:strip)

  while command = commands.shift
    if reply
      from      = reply.from
      from_name = reply.from_name
      text      = "#{command} #{reply.text}"
    else
      from      = @msg.from
      from_name = @msg.from_name
      text      = command
    end

    reply = Basil.dispatch(Basil::Message.new(Basil::Config.me, from, from_name, text))
  end

  reply if reply

}
