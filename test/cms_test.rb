ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'minitest/autorun'
require 'pry'

require_relative '../cms'

# Test for cms.rb
class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    # skip
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'about.md'
    assert_includes last_response.body, 'changes.txt'
    assert_includes last_response.body, 'history.txt'
  end

  def test_file
    # skip
    get '/history.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_includes last_response.body, 'history.txt'
    assert_includes last_response.body, '1995 - Ruby 0.95 released.'
  end

  def test_bad_file
    # skip
    get '/bad_file.ext'
    assert_equal 302, last_response.status

    get last_response['Location']

    assert_equal 200, last_response.status
    assert_includes last_response.body, 'bad_file.ext does not exist.'
  end

  def test_markdown
    get '/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<p><code>about.txt</code></p>'
  end

  def test_editing_document
    get '/changes.txt/edit'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<textarea'
    assert_includes last_response.body, '<button type=\'submit\''
  end

  def test_updating_document
    text = SecureRandom.uuid
    post '/test.txt', content: text

    assert_equal 302, last_response.status

    get last_response['Location']

    assert_includes last_response.body, 'test.txt has been updated'

    get '/test.txt'

    assert_equal 200, last_response.status
    assert_includes last_response.body, text
  end
end
