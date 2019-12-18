require 'erb'
require 'rack'
require 'active_support/all'

class View
     attr_reader :person, :time
    def initialize(user, time)
        @person = user
        @time = time
    end

    def file
        File.read(File.join(__dir__,"template.html.erb"))
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

class WebApp
    def initialize
        
    end
end
class Display
    def self.call(env)
        req = Rack::Request.new(env)
        if  req.path.match('/users/hema') && req.params["tz"] == "IST"
            user = User.new("hema")
            time = CountryTime.new("Kolkata")
            view = View.new(user, time)
            ['200', {"Content-Type" => "text/html"}, [view.render]]
        elsif
            req.path.match('/users/hery') && req.params["tz"] == "UTC"
            user = User.new("Hery")
            time = CountryTime.new("Eastern Time (US & Canada)")
            view = View.new(user, time)
            ['200', {"Content-Type" => "text/html"}, [view.render]]
        elsif
            req.path.match('/users/Cadu') && req.params["tz"] == "AST"
            user = User.new("Cadu")
            time = CountryTime.new("Asia/Kuwait")
            view = View.new(user, time)
            ['200', {"Content-Type" => "text/html"}, [view.render]]
        else
            [
                '404',
                {"Content-Type" => 'text/html'},
                ["<html><body><b><em>404 Page not found</em></b></body></html>"]
              ]
        end
    end

end



Rack::Server.start(app: Display).new
