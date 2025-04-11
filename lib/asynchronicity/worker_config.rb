module Asynchronicity
  class WorkerConfig
    attr_reader :redis_config

    def initialize(redis_config = {})
      @redis_config = redis_config
    end

    def redis
      host = @redis_config[:host] || "localhost"
      port = @redis_config[:port] || 6379
      db = @redis_config[:db] || 0
      @redis ||= Redis.new(host: host, port: port, db: db)
    end

    def namespace
      @redis_config[:namespace] || "asynchronicity"
    end
  end
end