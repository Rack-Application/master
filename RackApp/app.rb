require "erb"
require "rack"
require "active_support/time"

class MyController
  attr_reader :person, :time

  def initialize(user, time)
    @person = user
    @time = time
  end

  def file
    File.read(File.join(__dir__, "template.html.erb"))
  end

  def template
    ERB.new(file)
  end

  def render
    template.result(binding)
  end
end

class User
  attr_reader :nickname

  def initialize(nickname)
    @nickname = nickname
  end
end

class CountryTime
  attr_reader :zone, :timezone

  def initialize(zone)
    @zone = zone
  end

  def timezone
    Time.zone = @zone
    @time = Time.zone.now
  end
end

class Display
  def initialize(app)
    @app = app
  end

  def self.call(env)
    req = Rack::Request.new(env)
    nickname = req.params["nickname"]
    tz = req.params["tz"]
    if req.path.match("/users") && nickname && tz
      user = User.new("#{nickname}")
      time = CountryTime.new("#{tz}")
      view = MyController.new(user, time)
      ["200", { "Content-Type" => "text/html" }, [view.render]]
    else
      [
        "404",
        { "Content-Type" => "text/html" },
        ["<html><body><b><em>404 Page not found</em></b></body></html>"],
      ]
    end
  end
end

Rack::Server.start(app: Display).new
