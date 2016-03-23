require 'sinatra'
require 'tilt/erubis'

if development?
  require 'pry'
  require 'sinatra/reloader'
end

root = File.expand_path('..', __FILE__)

get '/' do
  @files = Dir.entries(root + '/data')
  @files.select! { |file| !File.directory? file }
  @files.sort!

  erb :index
end
