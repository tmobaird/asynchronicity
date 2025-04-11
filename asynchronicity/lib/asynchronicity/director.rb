module Asynchronicity
  class Director
    ALLOWED_ARG_TYPES = %w[plain complex]

    attr_reader :queues

    def initialize(config)
      @config = config
      @redis = config.redis
      @queues = Hash.new(nil)
      @queues[:main] = main_queue
      @queues[:retry] = retry_queue
      @queues[:failed] = failed_queue
    end

    def enqueue(classname, args, args_type)
      args = if args_type == "complex"
        JSON.parse(args)
      else
        args
      end

      klass = Work.job_class(classname)
      return unless klass

      begin
        klass = Work.job_class(classname)
        job = klass.new(args, nil)
        raw_enqueue(@main_queue, job)
      rescue NameError => e
        @logger.log("Work class with name #{classname} does not exist. Reason #{e.message}")
      end
    end

    def raw_enqueue(queue, job)
      queue.publish(Serializer.enqueue_format(job.class, job.args, job.error))
    end

    def find_queue(name)
      @queues[name.to_sym]
    end

    def enqueued(queue_name)
      find_queue(queue_name).enqueued.map do |work|
        Serializer.to_job(work)
      end
    end

    def available_jobs
      Work::BaseJob.subclasses
    end

    def main_queue
      @main_queue ||= Queue.new(@redis, @config.namespace, "main")
    end

    def retry_queue
      @retry_queue ||= Queue.new(@redis, @config.namespace, "retry")
    end

    def failed_queue
      @failed_queue ||= Queue.new(@redis, @config.namespace, "failed")
    end
  end
end
