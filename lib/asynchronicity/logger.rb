module Asynchronicity
  class Logger
    def initialize(io)
      @io = io
    end

    def log(message)
      @io.puts("[Asynchronicity] - #{Time.now.strftime("%F%T")}: #{message}")
    end
  end
end
