module Work
  class HelloJob < BaseJob
    def run
      puts "Hello, #{@args}"
    end
  end
end
