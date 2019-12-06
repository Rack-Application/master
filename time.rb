require 'rack'
require 'date'

class WebApplication
    def self.call(env)
        puts '[WebApplication]'
        current_time = Time.now.httpdate
        json = %Q(
        {
            "time": "#{current_time}"
        }
        )

        [200,{'Content-Type'=> 'application/json'}, [json]]
    end
end

class WebLogger
    def initialize(app)
        puts "The received app in WebLogger is: " + app.inspect
        @app = app
    end

    def call(env)
        puts "[WebLogger] calling #{@app}"
        @app.call(env)
    end
end

class HTMLWrapper
    def initialize(app)
        puts "The received app in HTMLWrapper is: " + app.inspect
        @app = app
    end

    def call(env)
        puts "[HTMLWrapper] calling #{@app}"
        status, headers, body = @app.call(env)
        headers['Content-Type'] = 'text/html'
        body_html = <<-HTML
        <html>
            <body>
                <code>
                #{body}
                </code>
            </body>
        </html>
        HTML
        [status, headers, [body_html]]

    end
end

app = Rack::Builder.app do
    use WebLogger
    use HTMLWrapper
    run WebApplication
end

# final_app = \
# WebLogger.new \
#   HTMLWrapper.new
#       WebApplication
#

Rack::Server.new(app: app).start

