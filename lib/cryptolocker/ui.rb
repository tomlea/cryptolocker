require "cryptolocker"
require "sinatra"

class Cryptolocker::UI < Sinatra::Application
  set :root, File.expand_path("../../../", __FILE__)

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def bounce_back_if_not_set_up!
    redirect("/") if Cryptolocker.initial_setup_mode?
  end

  def protect_and_bounce_back_if_not_set_up!
    bounce_back_if_not_set_up!
    protected!
  end

  def authorized?
    @user ||= load_user
  end

  helpers do
    attr_reader :user

    def admin?
      authorized? and user.username == "admin"
    end
  end

  def load_user
    auth =  Rack::Auth::Basic::Request.new(request.env)
    if auth.provided? && auth.basic? && auth.credentials
      username, password = auth.credentials
      return Cryptolocker::User.find(username, password)
    else
      false
    end
  end

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
    bounce_back_if_not_set_up!
    @message = "One does not simply GET the POST API end point."
    erb :error
  end

  get '/secure/private-key' do
    protect_and_bounce_back_if_not_set_up!
    if admin?
      content_type "text/plain"
      user.key
    else
      admin_only_message("Only the admin user can see the private key.")
    end
  end

  get '/secure/users' do
    protect_and_bounce_back_if_not_set_up!
    @users = Cryptolocker::User.all_names
    erb :users
  end

  post '/secure/users' do
    protect_and_bounce_back_if_not_set_up!
    return admin_only_message unless admin? or user.username == params[:username]
    user.grant_to_new_user!(params[:username], params[:password], params[:password_confirmation])
    redirect "/secure/users"
  end

  delete '/secure/users/:username' do
    protect_and_bounce_back_if_not_set_up!
    return admin_only_message unless admin? or user.username == params[:username]
    Cryptolocker::User.delete(params[:username])
    redirect "/secure/users"
  end

  def admin_only_message(message = "Admin only.")
    @message = message
    erb :error
  end

end
