# frozen_string_literal: true

require 'erb'
require 'rack'
require 'active_support/time'
require 'active_support/core_ext'
class MyController
  class_attribute :template_name, instance_writer: false
  self.template_name = 'template'
  attr_reader :person, :time
  def initialize(user, time)
    @person = user
    @time = time
  end

  def template(format)
    View.new(template_name, format)
  end

  def render_template(format)
    template(format).render.result(binding)
  end
end

class View
  def initialize(name, format)
    @erb = file(name, format)
  end

  def file(name, format)
    file_path = File.expand_path(File.join(__dir__, 'templates', "#{name}.#{format}.erb"), __FILE__)
    if File.exist?(file_path)
      File.read(File.join(__dir__, 'templates', "#{name}.#{format}.erb"))
    else
      'ERROR:The file doesnot exist'
    end
  end

  def render
    ERB.new(@erb)
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
    Time.zone = zone
    @timezone = Time.zone.now
  end
end

class MyApp
  def initialize(app = nil)
    @app = app
  end

  def call(env)
    @app&.call(env)
    req = Rack::Request.new(env)
    timezone = req.params['timezone']
    format = req.params['format']
    nickname_match = req.path.match('/users/nickname/(\w+)')
    nickname = nickname_match[1] if nickname_match
    if nickname && timezone && format
      user = User.new(nickname)
      time = CountryTime.new(timezone.to_s)
      view = MyController.new(user, time)
      ['200', { 'Content-Type' => response_format(format) }, [view.render_template(format)]]
    else
      [
        '404',
        { 'Content-Type' => 'text/html' },
        ['<html><body><b><em>404 Page not found</em></b></body></html>']
      ]
      end
  end

  def response_format(format)
    case format
    when /html/
      'text/html'
    when /json/
      'application/json'
    when /xml/
      'application/xml'
    end
  end
end

Rack::Server.start(app: MyApp.new).new
