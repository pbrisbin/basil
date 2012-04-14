Basil.respond_to(%r{^match (.*) /(.*)/$}) {

  says do |out|
    if m = /#{@match_data[2]}/.match(@match_data[1])
      out << "match:"
      out << m.inspect
    else
      out << "no match."
    end
  end

}
