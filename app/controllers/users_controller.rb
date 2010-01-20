class UsersController < ApplicationController
  
  require 'digest/md5'
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @users = User.paginate :per_page => session[:list_limit],
                           :page => params[:page]
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    # Only allow user id 1 here (admin user)
    if session[:user] != 1
      flash[:error] = "Only admin user has permission to add users!"
      redirect_to :back
    else
      @user = User.new
    end
  end

  def create
    # Only allow user id 1 here (admin user)
    if session[:user] != 1
      flash[:error] = "Only admin user has permission to add users!"
      redirect_to :back
    else
      @user = User.new(params[:user])
      if @user.save
        # We need to hash the passwords, after a successful save
        @user.update_attribute :password, Digest::MD5.hexdigest(params[:user][:password])
        @user.update_attribute :pin, Digest::MD5.hexdigest(params[:user][:pin])

        # We now need to encrypt the key, after a successfult save
        @user.encrypt_key params[:user][:decrypted_key]
        @user.reload
        flash[:notice] = 'User was successfully created.'
        redirect_to :action => 'list'
      else
        flash[:error] = "User could not be created."
        render :action => 'new'
      end
    end
  end

  def edit
    # If user is not admin, they can only edit their own details
    logger.debug("DEBUG >> users/edit #{params[:id]} requested by user #{session[:user]}")
    if session[:user] == 1 || session[:user] == params[:id].to_i
      @user = User.find(params[:id])
      # Blank out the password & PIN for display
      @user.password = nil
      @user.pin = nil
    else
      flash[:error] = "You can only edit your own details!"
      redirect_to :controller => 'cp'
    end
  end

  def update
    if session[:user] == 1 || session[:user] == params[:id].to_i
      @user = User.find(params[:id])
      # If the passwords are both empty, we don't want to update the password
      if params[:user][:password] != ''
        logger.debug("DEBUG >> Password field was not empty")
        update_password = true
      else
        logger.debug("DEBUG >> Password field was empty")
        update_password = false
        params[:user][:password] = @user.password 
        params[:user][:password_confirmation] = @user.password
      end

      # If the PINs are both empty, we don't want to update the PIN
      if params[:user][:pin] != ''
        logger.debug("DEBUG >> PIN field was not empty")
        update_pin = true
      else
        logger.debug("DEBUG >> PIN fields was empty")
        update_pin = false
        params[:user][:pin] = @user.pin 
        params[:user][:pin_confirmation] = @user.pin
      end

      if @user.update_attributes(params[:user])
        # We need to hash the passwords, after a successful save
        logger.debug("DEBUG >> Password was changed, hashing it now...")
        @user.update_attribute :password, Digest::MD5.hexdigest(params[:user][:password]) unless update_password == false
        if update_pin
          # We now need to encrypt the key, after a successfult save
          logger.debug("DEBUG >> PIN was changed, hashing it and re-encrypting key now...")
          @user.update_attribute :pin, Digest::MD5.hexdigest(params[:user][:pin])
          @user.encrypt_key params[:user][:decrypted_key]
          @user.reload
        end
        # Reload our list_limit session var.
        session[:list_limit] = @user.list_limit
        flash[:notice] = "User was successfully edited."
        # We're usually called from control pane, so redirect there.
        redirect_to :controller => 'cp'
      else
        render :action => 'edit'
      end
    else
      flash[:error] = "You can only update your own details!"
      redirect_to :back
    end
  end

  def destroy
    begin
      User.find(params[:id]).destroy
    rescue
      flash[:error] = "You can't delete the admin user!"
    end
    redirect_to :action => 'list'
  end
end
