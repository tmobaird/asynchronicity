module Asynchronicity
  class SortedQueue < Queue
    def peek
      @redis.zrange(@redis_key, 0, 0, byscore: true)&.first
    end

    def consume
      @redis.zpopmin(@redis_key)&.first
    end

    def publish(data)
      @redis.zadd(@redis_key, data.first, data.last)
    end

    def count
      @redis.zcard(@redis_key)
    end

    def enqueued
      @redis.zrange(@redis_key, 0, -1)
    end
  end
end
