require "cryptolocker"
require "sinatra"

class Cryptolocker::UI < Sinatra::Application
  set :root, File.expand_path("../../../", __FILE__)
  
  get "/" do
    if Cryptolocker.initial_setup_mode?
      erb :setup
    else
      erb :index
    end
  end

  post '/first-account-setup' do
    Cryptolocker::User.create!(params[:username], params[:password], params[:password_confirmation])
    redirect("/")
  end

  get '/submit' do
    @message = "One does not simply GET the POST API end point."
    erb :error
  end

end
