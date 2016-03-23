require 'sinatra'
require 'sinatra/reloader'
require 'pry' if development?

get '/' do
  'Getting started.'
end
