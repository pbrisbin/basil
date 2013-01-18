require 'optparse'

module Basil
  class Options
    attr_reader :config

    def initialize(config = Config)
      @config = config
    end

    def parse(argv)
      OptionParser.new do |o|
        o.banner =  'usage: basil [options] [start|stop|restart]'
        o.separator ''
        o.on(       '--cli',           'Run the CLI server'    ) { config.server = Cli.new }
        o.on(       '--debug',         'Log at the DEBUG level') { Loggers.level = 0 } # DEBUG
        o.on(       '--quiet',         'Turn off all logging'  ) { Loggers.level = 6 } # OFF
        o.separator ''
        o.on(       '--daemon',        'Daemonize self'   ) { config.background = true }
        o.on(       '--pid-file FILE', 'PID file location') { |f| config.pid_file = f }
        o.on(       '--log-file FILE', 'Log file location') { |f| config.log_file = f }
        o.separator ''
      end.parse!(argv)

      argv
    end
  end
end
