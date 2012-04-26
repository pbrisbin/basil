module Basil
  class Config
    # a very short list of things we can change via chat
    def self.accessible?(key)
      [ 'me',
        'plugins_directory',
        'pstore_file',
        'extended_readline'
      ].include?(key)
    end

    # parses strings to some simple types
    def self.cast(str)
      return true     if str == "true"
      return false    if str == "false"
      return str.to_i if str.to_i.to_s == str

      str
    end
  end
end

Basil.respond_to(/^config get (\S+)$/) {

  key = @match_data[1].strip

  if Basil::Config.accessible?(key)
    says "=> #{Basil::Config.yaml[key]}"
  end

}

Basil.respond_to(/^config set (\S+) (.+)$/) {

  key, value = @match_data.captures.map(&:strip)

  if Basil::Config.accessible?(key)
    says "=> #{Basil::Config.yaml[key] = Basil::Config.cast(value)}"
  end

}
