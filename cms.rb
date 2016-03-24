require 'sinatra'
require 'tilt/erubis'
require 'redcarpet'

if development?
  require 'pry'
  require 'sinatra/reloader'
end

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

ROOT = File.expand_path('..', __FILE__)

def file_path(file_name)
  ROOT + '/data/' + file_name
end

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when '.md'
    render_markdown content
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    content
  end
end

def data_files
  @files = Dir.entries(ROOT + '/data')
  @files.select! { |file| !File.directory? file }
  @files.sort!
end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

get '/' do
  @files = data_files

  erb :index
end

get '/:file_name' do
  file_name = params[:file_name]

  if File.exist? file_path(file_name)
    load_file_content(file_path(file_name))
  else
    session[:message] = "#{file_name} does not exist."

    redirect '/'
  end
end

get '/:file_name/edit' do
  @file_name = params[:file_name]
  @file_content = File.read(file_path(@file_name))

  erb :edit
end

post '/:file_name' do
  file_name = params[:file_name]
  File.write(file_path(file_name), params[:content])

  session[:message] = "#{file_name} has been updated."
  redirect '/'
end
