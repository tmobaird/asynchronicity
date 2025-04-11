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
        begin
          klass = Work.job_class(classname)
          klass.new(args, error)
        rescue NameError => e
          @logger.log("Work class with name #{classname} does not exist. Reason #{e.message}")
        end
      end
    end
  end
end
