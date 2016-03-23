ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'minitest/autorun'

require_relative '../cms'

# Test for cms.rb
class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal 'lalala', last_response.body
  end
end
