require "json"

module Asynchronicity
  class Serializer
    class << self
      def serialize(data)
        data.to_json
      end

      def deserialize(data)
        JSON.parse(data)
      end

      def enqueue_format(klass, args, error = nil)
        {class: klass.to_s, args: args, error: error}.to_json
      end

      def to_job(data)
        deserialized = deserialize(data)
        classname = deserialized["class"]
        args = deserialized["args"]
        error = deserialized["error"]
        retry_count = deserialized["retry_count"]
        next_run_at = deserialized["next_run_at"] && Time.at(deserialized["next_run_at"])

        begin
          klass = Work.job_class(classname)
          klass.new(args, error, retry_count, next_run_at)
        rescue NameError => e
          @logger.log("Work class with name #{classname} does not exist. Reason #{e.message}")
        end
      end

      def from_job(job)
        job.to_json
      end
    end
  end
end
