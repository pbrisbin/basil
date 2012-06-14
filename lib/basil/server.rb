module Basil
  class Server
    attr_reader :delegate

    def initialize(delegate)
      @delegate = delegate
    end
  end
end
