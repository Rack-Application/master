# frozen_string_literal: true

require 'erb'
require 'rack'
require 'active_support/time'

class MyController
  attr_reader :person, :time

  def initialize(user, time)
    @person = user
    @time = time
  end

  def file(format)
    File.read(File.join(__dir__, "template.#{format}.erb"))
  end

  def template(format)
    ERB.new(file(format))
  end

  def render(format)
    template(format).result(binding)
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
  def initialize(app = nil)
    @app = app
  end

  def call(env)
    @app&.call(env)
    req = Rack::Request.new(env)
    format = request_format(env)
    puts env.inspect
    nickname = req.params['nickname']
    tz = req.params['tz']
    f = req.params['f']
    if req.path.match('/users') && nickname && tz && f
      user = User.new(nickname.to_s)
      time = CountryTime.new(tz.to_s)
      view = MyController.new(user, time)
      ['200', { 'Content-Type' => response_format(format) }, [view.render(f)]]
    else
      [
        '404',
        { 'Content-Type' => 'text/html' },
        ['<html><body><b><em>404 Page not found</em></b></body></html>']
      ]
    end
  end

  def request_format(env)
    format = env['HTTP_ACCEPT'].split(',').first.to_s
    case format
    when /json/
      :json
    when /html/
      :html
    when /xml/
      :xml
    else
      raise ClientError, "Format not accepted: #{format}"
    end
  end

  def response_format(format)
    case format
    when :html
      'text/html'
    when :json
      'application/json'
    when :xml
      'application/xml'
    end
  end
end

Rack::Server.start(app: Display.new).new

