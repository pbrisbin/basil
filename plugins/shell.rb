#
# This is dangerous, limited to authorized users only -- raw shell
# access.
#
Basil::Plugin.respond_to(/^sh (.*)/) {

  require_authorization do
    out = nil
    cmd = @match_data[1].strip rescue ''

    if cmd != ''
      require 'timeout'
      Timeout::timeout(30) do
        out = `#{@match_data[1]} 2>&1`
      end
    end

    says out if out
  end

}
