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
        process_next(@director.main_queue)
        process_next_retry
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

    # TODO: #process_next and #process_next_retry
    # need to be cleaned up
    # they are almost exactly the same,
    # minus the way that retry will enqueue things
    # if it is not workable yet (which is not a concept for the main queue)
    def process_next(queue)
      work = queue.consume # consume
      return unless work

      job = Serializer.to_job(work)
      if job&.process?
        log_start_message(job)
        begin
          job.run
        rescue => e
          @logger.log("#{job.class} failed. Reason #{e.message}")

          job.retry_count += 1
          job.next_run_at = Time.now.to_i + (30 * job.retry_count) # 30, 60, 90, 120, 150
          job.error = e.message

          if job.retry_count < job.allowed_retries
            @director.raw_enqueue(@director.retry_queue, job, weight: job.weight)
          else
            @director.raw_enqueue(@director.failed_queue, job)
          end
        end
        @logger.log("#{job.class} done.")
      else
        @logger.log("Could not process work with data: #{work}")
      end
    end

    def process_next_retry
      work = @director.retry_queue.consume
      return unless work

      job = Serializer.to_job(work)
      if job&.process?
        log_start_message(job)
        begin
          job.run
        rescue => e
          @logger.log("#{job.class} failed. Reason #{e.message}")

          job.retry_count += 1
          job.next_run_at = Time.now.to_i + (30 * job.retry_count) # 30, 60, 90, 120, 150
          job.error = e.message

          if job.retry_count < job.allowed_retries
            @director.raw_enqueue(@director.retry_queue, job, weight: job.weight)
          else
            @director.raw_enqueue(@director.failed_queue, job)
          end
        end
        @logger.log("#{job.class} done.")
      elsif job.nil?
        @logger.log("Could not process work with data: #{work}")
      else
        @logger.log("Not ready to run: #{work}")
        @director.raw_enqueue(@director.retry_queue, job, weight: job.weight)
      end
    end

    def log_start_message(job)
      verb = (job.retry_count > 0) ? "rerunning" : "starting"
      @logger.log("#{job.class} #{verb} with #{job.args}")
    end
  end
end
