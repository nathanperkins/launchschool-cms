require 'sinatra'
require 'tilt/erubis'

if development?
  require 'pry'
  require 'sinatra/reloader'
end

ROOT = File.expand_path('..', __FILE__)

get '/' do
  @files = data_files
  erb :index
end

get '/:file_name' do
  file_name = params[:file_name]

  if File.exist? file_path(file_name)
    file = File.open file_path(file_name)
    headers['Content-Type'] = 'text/plain'
    return file.read
  else
    status 404
    session[:error] = "#{file_name} does not exist."
    @files = data_files

    erb :index
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
