require 'rack'
require 'date'

class WebApplication
    def self.call(env)
        
        current_time = Time.now.httpdate
    
        [200,{'Content-Type'=> 'text/html'}, [current_time]]
    end
end

Rack::Server.start(app: WebApplication)
