module Work
  class << self
    def work_path
      File.expand_path File.dirname(__FILE__) + "/work/**/*.rb"  
    end

    def job_class(classname)
      begin
        Work.const_get(classname)
      rescue NameError => e
        nil
      end
    end
  end
end

require_relative "work/base_job"
Dir[Work.work_path].each { |f| require f }