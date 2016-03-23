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
    assert_includes last_response.body, 'about.txt'
    assert_includes last_response.body, 'changes.txt'
    assert_includes last_response.body, 'history.txt'
  end

  def test_file
    get '/about.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_includes last_response.body, 'about.txt'
    assert_includes last_response.body, '1996 - Ruby 1.0 released.'
  end

  def test_bad_file
    get '/non_existent.txt'
    assert_equal 404, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'non_existent.txt does not exist.'
  end
end
