module Work
  class BaseJob
    attr_reader :args
    attr_accessor :error

    def initialize(args, error = nil)
      @args = args
      @error = error
    end

    def run
      raise "You must implement this yourself"
    end
  end
end
