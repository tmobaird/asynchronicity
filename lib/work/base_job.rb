module Work
  class BaseJob
    attr_reader :args
    attr_accessor :error, :retry_count, :next_run_at

    def initialize(args, error = nil, retry_count = nil, next_run_at = nil)
      @args = args
      @error = error
      @retry_count = retry_count || 0
      @next_run_at = next_run_at
    end

    def run
      raise "You must implement this yourself"
    end

    def allowed_retries
      5
    end

    def process?
      @next_run_at.nil? || Time.now >= @next_run_at
    end

    def to_json
      {
        class: self.class.to_s,
        args: @args,
        error: @error,
        retry_count: @retry_count,
        next_run_at: serialized_next_run_at
      }.to_json
    end

    def weight
      serialized_next_run_at
    end

    def serialized_next_run_at
      @next_run_at&.to_i
    end
  end
end
