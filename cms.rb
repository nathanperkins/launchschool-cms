require 'sinatra'
require 'tilt/erubis'
require 'redcarpet'

if development?
  require 'pry'
  require 'sinatra/reloader'
end

set :sessions, true

ROOT = File.expand_path('..', __FILE__)

get '/' do
  @files = data_files

  erb :index
end

get '/:file_name' do
  file_name = params[:file_name]

  if File.exist? file_path(file_name)
    if file_name =~ /.md/
      render_markdown file_name
    else
      headers['Content-Type'] = 'text/plain'
      File.read(file_path(file_name))
    end
  else
    session[:message] = "#{file_name} does not exist."

    redirect '/'
  end
end

def file_path(file_name)
  ROOT + '/data/' + file_name
end

def data_files
  @files = Dir.entries(ROOT + '/data')
  @files.select! { |file| !File.directory? file }
  @files.sort!
end

def render_markdown(file_name)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render File.read(file_path(file_name))
end
