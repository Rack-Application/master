# frozen_string_literal: true

require 'test/unit'
require 'rack/test'

class TestBase < Test::Unit::TestCase
  include Rack::Test::Methods
end
