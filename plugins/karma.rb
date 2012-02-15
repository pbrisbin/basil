# when foo-- or foo++ is mentioned in conversation, foo's karma is
# decremented or incremented.
Basil.watch_for(/(\w+)(--|\+\+)($|[!?.,:; ])/) {

  k  = @match_data[1]
  op = @match_data[2]

  Basil::Storage.with_storage do |store|
    store[:karma_tracker]    ||= {}
    store[:karma_tracker][k] ||= 0

    case op
    when '--' then store[:karma_tracker][k] -= 1
    when '++' then store[:karma_tracker][k] += 1
    end
  end

  nil

}

Basil.respond_to(/^karma (\w+)/) {

  k = @match_data[1]
  karma = 0

  Basil::Storage.with_storage do |store|
    karma = store[:karma_tracker][k] || 0
  end

  msg = if karma == 0
          "nuetral karma"
        elsif karma > 0
          "positive karma (+#{karma})"
        else
          "negative karma (#{karma})"
        end

  replies "#{k} currently has #{msg}"

}.description = "report a word's current karma"
