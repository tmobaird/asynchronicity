module Work
  class HelloFriendsJob < BaseJob
    def run
      puts "Hello, #{@args.join(", ")}"
    end
  end
end
