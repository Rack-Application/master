# frozen_string_literal: true

require 'erb'
require 'rack'

class User
  attr_reader :nickname

  def initialize(nickname)
    @nickname = nickname
  end
end

class Browser
  attr_reader :user_agent

  def initialize(type)
    @user_agent = type
  end
end

class MyController
  attr_reader :person, :navigator, :code

  def initialize
    @person = User.new('Srijita')
    @code = 'Ruby'
  end

  def call(env)
    @navigator = Browser.new(env['HTTP_USER_AGENT'])
    env['rack.view'] = View.new(self)
  end

  def get_binding
    binding
  end
end

###### RAILS WILL GENERATE THOSE BOILERPLATE FOR YOU

class View
  def initialize(controller)
    @controller = controller
  end

  def file(format)
    File.read(File.join(__dir__, "template.#{format}.erb"))
  end

  def template(format)
    ERB.new(file(format))
  end

  def render(format)
    template(format).result(@controller.get_binding)
  end
end

class MyApp
  class ClientError < StandardError
  end

  def initialize(app=nil)
    @app = app
  end

  def call(env)
    @app.call(env) if @app
    format = request_format(env)

    [200, {'Content-Type' => response_format(format)}, [view(env).render(format)]]
  rescue ClientError => error
    [406, {'Content-Type' => 'text/plain'}, [error.message]]
  end

  def view(env)
    env['rack.view']
  end

  def request_format(env)
    format = env['HTTP_ACCEPT'].split(',').first.to_s
    case format
    when /json/
      :json
    when /html/
      :html
    else
      raise ClientError.new("Format not accepted: #{format}")
    end
  end

  def response_format(format)
    case format
    when :html
      'text/html'
    when :json
      'application/json'
    end
  end
end

app = Rack::Builder.new do
  use MyApp
  run MyController.new
end

Rack::Server.new(app: app).start
