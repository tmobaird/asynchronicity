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
    rescue SystemExit, Interrupt => e
      @logger.log("Stopping")
      exit(0)
    end

    private

    def setup
      return if @redis.exists?("#{@config.namespace}:queue") # && of proper type
      @redis.del("#{@config.namespace}:queue") # will be automatically created on push
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
          job.error = e.message
          @director.raw_enqueue(@director.failed_queue, job)
        end
        @logger.log("#{job.class} done.")
      else
        @logger.log("Could not process work with data: #{work}")
      end
    end
  end
end
