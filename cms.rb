require 'sinatra'
require 'tilt/erubis'

if development?
  require 'pry'
  require 'sinatra/reloader'
end

ROOT = File.expand_path('..', __FILE__)

get '/' do
  @files = Dir.entries(ROOT + '/data')
  @files.select! { |file| !File.directory? file }
  @files.sort!

  erb :index
end

get '/:file_name' do
  headers['Content-Type'] = 'text/plain'

  File.read file_path(params[:file_name])
end

def file_path(file_name)
  ROOT + '/data/' + params[:file_name]
end