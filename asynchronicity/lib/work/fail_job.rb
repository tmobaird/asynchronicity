module Work
  class FailJob < BaseJob
    def run
      raise "I am the fail job, I must fail"
    end
  end
end
