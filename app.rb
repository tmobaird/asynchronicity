require "sinatra"
require "debug"
require_relative "lib/asynchronicity"

get "/", provides: "html" do
  @asynchronicity = Asynchronicity.new
  erb :"index.html", layout: :"layouts/application.html"
end

get "/jobs/new" do
  @asynchronicity = Asynchronicity.new
  erb :"new.html", layout: :"layouts/application.html"
end

post "/jobs" do
  type = params["work_type"]
  args = params["args"]
  args_type = params["args_type"]
  Asynchronicity.new.enqueue(type, args, args_type)

  redirect to("/")
end

get "/queues/:name" do
  name = params["name"]
  @asynchronicity = Asynchronicity.new
  @queue = Asynchronicity.new.find_queue(name)

  erb :"queues/show.html", layout: :"layouts/application.html"
end

get "/*" do
  erb :"not_found.html", layout: :"layouts/application.html"
end