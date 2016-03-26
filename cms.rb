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

def data_path
  if ENV['RACK_ENV'] == 'test'
    File.expand_path('../test/data', __FILE__)
  else
    File.expand_path('../data', __FILE__)
  end
end

def file_path(file_name)
  File.join(data_path, file_name)
end

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when '.md'
    erb(render_markdown(content))
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    content
  end
end

def error_for_new_file(file_name)
  unless (1..100).cover? file_name.size
    return 'File name must be between 1 and 100 characters.'
  end

  nil
end

def data_files
  @files = Dir.entries(data_path)
  @files.select! { |file| !File.directory? file }
  @files.sort!
end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text).prepend('<body>').concat('</body>')
end

def logged_in?
  !!session[:user]
end

def must_be_logged_in
  unless logged_in?
    session[:message] = 'You must be signed in to do that.'
    redirect '/'
  end
end

get '/' do
  @files = data_files

  erb :index
end

get '/new' do
  must_be_logged_in

  erb :new
end

post '/create' do
  must_be_logged_in

  file_name = params[:file_name]

  error = error_for_new_file(file_name)
  if error
    status 422
    session[:message] = error

    redirect '/new'
  else
    File.write(file_path(file_name), '')
    session[:message] = "#{file_name} has been created."

    redirect '/'
  end
end

get '/:file_name' do
  file_name = params[:file_name]

  if File.exist? file_path(file_name)
    content = load_file_content(file_path(file_name))
    content
  else
    session[:message] = "#{file_name} does not exist."

    redirect '/'
  end
end

get '/:file_name/edit' do
  must_be_logged_in

  @file_name = params[:file_name]
  @file_content = File.read(file_path(@file_name))

  erb :edit
end

post '/:file_name' do
  must_be_logged_in

  file_name = params[:file_name]
  File.write(file_path(file_name), params[:content])
  session[:message] = "#{file_name} has been updated."

  redirect '/'
end

post '/:file_name/delete' do
  must_be_logged_in

  file_name = params[:file_name]
  if File.exist? file_path(file_name)
    session[:message] = "#{file_name} was deleted."
    File.delete file_path(file_name)
  else
    session[:message] = "#{file_name} does not exist."
  end

  redirect '/'
end

get '/users/signin' do
  erb :signin
end

post '/users/signin' do
  username = params[:username]
  password = params[:password]

  if username == 'admin' && password == 'secret'
    session[:user] = username
    session[:message] = "Welcome, #{username}!"

    redirect '/'
  else
    status 422
    session[:message] = 'Invalid credentials.'
    erb :signin
  end
end

post '/users/signout' do
  must_be_logged_in
  
  session[:user] = nil
  session[:message] = 'You have been signed out.'

  redirect '/'
end
