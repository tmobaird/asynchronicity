require "time"

module Asynchronicity
  class Worker
    def initialize(config)
      @config = config
      @redis = config.redis
      @queue = Queue.new(@redis, @config.namespace, "main")
      @director = Director.new(@config)
      @logger = Logger.new($stdout)
    end

    def run
      @logger.log("Starting worker...")
      setup

      Kernel.loop do
        process_next(@queue)
      end
    rescue SystemExit, Interrupt => _
      @logger.log("Stopping")
      exit(0)
    end

    private

    def setup
      return if @redis.exists?("#{@config.namespace}:queue")
      @redis.del("#{@config.namespace}:queue")
    end

    def process_next(queue)
      work = queue.consume # consume
      return unless work

      job = Serializer.to_job(work)
      if job
        @logger.log("#{job.class} starting with #{job.args}")
        begin
          job.run
        rescue => e
          @logger.log("#{job.class} failed. Reason #{e.message}")

          job.retry_count += 1
          job.next_run_at = Time.now.to_i + (30 * job.retry_count) # 30, 60, 90, 120, 150
          job.error = e.message

          to_send = (job.retry_count < job.allowed_retries) ? @director.retry_queue : @director.failed_queue
          @director.raw_enqueue(to_send, job)
        end
        @logger.log("#{job.class} done.")
      else
        @logger.log("Could not process work with data: #{work}")
      end
    end
  end
end
