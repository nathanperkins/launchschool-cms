ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'minitest/autorun'
require 'pry'
require 'fileutils'

require_relative '../cms'

# Test for cms.rb
class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = '')
    File.open(file_path(name), 'w') do |file|
      file.write(content)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def test_index
    # skip
    create_document('about.md')
    create_document('changes.txt')
    create_document('history.txt')

    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'about.md'
    assert_includes last_response.body, 'changes.txt'
    assert_includes last_response.body, 'history.txt'
  end
  # rubocop:enable Metrics/AbcSize

  def test_file
    # skip
    create_document('history.txt', 'history.txt\n1995 - Ruby 0.95 released.')

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
    create_document('about.md', '``about.txt``')

    get '/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<p><code>about.txt</code></p>'
  end

  def test_editing_document
    create_document('changes.txt')
    get '/changes.txt/edit'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<textarea'
    assert_includes last_response.body, '<button type=\'submit\''
  end

  # rubocop:disable Metrics/AbcSize
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
  # rubocop:enable Metrics/AbcSize
end
