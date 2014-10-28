require 'sinatra'
require 'sinatra/synchrony'

require 'haml'
require 'sqlite3'
require 'securerandom'
require 'digest/md5'
require 'digest/sha1'
require 'digest'
require 'thin'
require 'fileutils'
require 'sequel'
require 'logger'
require 'openssl'

STDOUT.sync = true

use Rack::Session::Pool

post '/' do
  user = params[:user]

  if user[:email] != user[:emailAgain] 
    session[:flash] = "Email address does not match entered details"
    redirect to('/')
    return
  end
  user.delete('emailAgain')
  
  if user[:password] != user[:passwordAgain]
    session[:flash] = "Password does not match"
    redirect to('/')
    return
  end
  user.delete('passwordAgain')

  if user[:admin].nil?
    session[:flash] = "User is not an admin :<"
    redirect to("/")
    return
  end

  session[:flash] = "User is an admin!"
  session[:worked] = true
  redirect to('/worked')
end

get '/worked' do
  if session[:worked].nil?
    session[:flash] = "You have not passed this level"
    redirect to('/')
    return
  end

  html = haml :worked, :locals => { :flash => session[:flash] }
  session.delete(:flash)
  html
end

get '/' do  
  html = haml :index, :locals => { :flash => session[:flash] }
  session.delete(:flash)
  html
end


