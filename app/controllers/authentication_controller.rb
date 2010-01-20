class AuthenticationController < ApplicationController
  
  def index
  end
  
  def login
    if request.post?
      begin
        user = User.authenticate(params[:username], params[:password], params[:pin])
        session[:user] = user.id
        session[:user_name] = user.name
        session[:list_limit] = user.list_limit
      rescue
        flash[:error] = "Username, password and/or pin invalid."
        redirect_to :action => "login" and return
      end
      if session[:intended_controller] != nil or session[:intended_action] != nil
        redirect_to :controller => session[:intended_controller],
                    :action => session[:intended_action],
                    :id => session[:intended_id]
        # Clear the intended controller & action
        session[:intended_controller] = nil
        session[:intended_action] = nil
        session[:intended_id] = nil
      else
        redirect_to :controller => "main", :action => "index"
      end
    end
  end
  
  def logout
    session[:user] = nil
    redirect_to :action => "login"
  end
  
end
