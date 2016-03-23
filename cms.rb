require 'sinatra'
require 'sinatra/reloader'

if development?
  require 'pry'
end

get '/' do
  'Getting started.'
end