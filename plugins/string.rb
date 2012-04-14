Basil.respond_to(/^('|")(.*?)\1\.([^\s\(]+)( (.*)|\((.*)\))?/) {

  str  = @match_data[2]
  meth = @match_data[3]
  args = (@match_data[5] || @match_data[6]).split(/, ?/) rescue []

  args = args.map { |arg| arg =~ /^('|")(.*)\1$/ ? $2 : arg     }
  args = args.map { |arg| arg.to_i.to_s == arg ? arg.to_i : arg }

  says "#{str.send(meth, *args)}"

}
