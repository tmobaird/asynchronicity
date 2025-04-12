module Asynchronicity
  class Queue
    SHOW_ERRORS = %w[retry failed]

    attr_reader :name, :prefix

    def initialize(redis, namespace, name = "main")
      @redis = redis
      @redis_key = "#{namespace}:#{name}"
      @name = name
    end

    def consume
      @redis.rpop(@redis_key)
    end

    def publish(data)
      @redis.rpush(@redis_key, data)
    end

    def count
      @redis.llen(@redis_key)
    end

    def enqueued
      @redis.lrange(@redis_key, 0, -1)
    end

    def main?
      @name == "main"
    end

    def retry?
      @name == "retry"
    end

    def failed?
      @name == "failed"
    end

    def can_have_error?
      SHOW_ERRORS.include? @name
    end
  end
end
