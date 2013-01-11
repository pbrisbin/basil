require 'optparse'

module Basil
  class Options
    attr_reader :config

    def initialize(config = Config)
      @config = config
    end

    def parse(argv)
      OptionParser.new do |o|
        o.banner =  'usage: basil [options]'
        o.separator ''
        o.on(       '--cli',     'Run the CLI server'        ) { config.server = Cli.new }
        o.on(       '--debug',   'Log at the DEBUG level'    ) { Loggers.level = 0 } # DEBUG
        o.on(       '--quiet',   'Turn off all logging'      ) { Loggers.level = 6 } # OFF
        o.on(       '--version', 'Output version information') { puts VERSION; exit }
        o.separator ''
      end.parse!(argv)

      argv
    end
  end
end
