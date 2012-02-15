Basil.log do
  Basil::Storage.with_storage do |store|
    store[:last_seen] ||= {}
    store[:last_seen][@msg.from] = { :name => @msg.from_name, :when => Time.now }
  end
end

Basil.respond_to(/^seen (.+?)\??$/) {

  seen = nil

  Basil::Storage.with_storage do |store|
    store[:last_seen] ||= {}
    store[:last_seen].each_value do |v|
      $stderr.puts @match_data.inspect
      if v[:name] =~ /#{@match_data[1].strip}/i
        seen = v
        break
      end
    end
  end

  seen ? replies("#{seen[:name]} was last seen on #{seen[:when].strftime("%D, at %r")}.") : nil

}.description = "displays when the person was last seen in chat"
