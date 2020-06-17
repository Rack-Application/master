# frozen_string_literal: true

require 'test_helper'
require 'active_support/json'
require 'nokogiri'
require 'active_support/core_ext'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

class TestApp < TestBase
  def app
    OUTER_APP
  end

  def test_jsonoutput
    Time.zone = 'UTC'
    @timezone = Time.zone.now
    data = { 'name' => 'hema', 'time' => @timezone.to_s }
    json_data = JSON.parse(data.to_json).to_s
    get '/users/nickname/hema?timezone=UTC&format=json'
    response = JSON.parse(last_response.body).to_s
    assert_equal response, json_data
  end

  def test_xmloutput
    Time.zone = 'UTC'
    @timezone = Time.zone.now
    data = { 'person' => 'hema', 'time' => @timezone.to_s }
    data1 = data.to_xml(root: 'output')
    get '/users/nickname/hema?timezone=UTC&format=xml'
    assert_equal last_response.body, data1
  end

  def test_htmloutput
    personname = 'hema'
    Time.zone = 'UTC'
    @timezone = Time.zone.now
    data = <<-HTML
        <html>
            <head>
              <b>
              persons nick name is #{personname} and current time in the timezone is #{@timezone}
              </b>
            </head>
        </html>
    HTML
    puts parsed_data = Nokogiri::HTML.parse(data).to_s
    get '/users/nickname/hema?timezone=UTC&format=html'
    response = Nokogiri::HTML.parse(last_response.body).to_s
    assert_equal last_response.body, parsed_data
  end

  def test_pagenotfound
    get '/users/nickname'
    assert_equal last_response.body, '<html><body><b><em>404 Page not found</em></b></body></html>'
  end

  def test_undefinedfileformat
    get '/users/nickname/hema?timezone=UTC&format=xtml'
    assert_equal last_response.body, 'ERROR:The file doesnot exist'
  end
end
