Basil.respond_to(/^(\d+)\.([^\s\(]+)( (.*)|\((.*)\))?/) {

  int  = @match_data[1].to_i
  meth = @match_data[2]
  args = (@match_data[4] || @match_data[5]).split(/, ?/) rescue []

  args = args.map { |arg| arg =~ /^('|")(.*)\1$/ ? $2 : arg     }
  args = args.map { |arg| arg.to_i.to_s == arg ? arg.to_i : arg }

  says "#{int.send(meth, *args)}"

}
