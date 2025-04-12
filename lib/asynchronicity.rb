module Asynchronicity
  def self.new
    Asynchronicity::Director.new(Asynchronicity::WorkerConfig.new)
  end
end

require "redis"
require "debug"
require_relative "work"
require_relative "asynchronicity/worker_config"
require_relative "asynchronicity/serializer"
require_relative "asynchronicity/queue"
require_relative "asynchronicity/sorted_queue"
require_relative "asynchronicity/logger"
require_relative "asynchronicity/worker"
require_relative "asynchronicity/director"
