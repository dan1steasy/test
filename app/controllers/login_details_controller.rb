class LoginDetailsController < ApplicationController
  require 'login_detail'

  in_place_edit_for :login_detail, :description
  in_place_edit_for :login_detail, :decrypted_username
  in_place_edit_for :login_detail, :decrypted_password

  # The new method is for AccountLogins by default - may
  # want/need to change this to new_account_login in future
  # if we start storing logins against companies & contacts.
  def new
    @account_login = AccountLogin.new(User.find(session[:user]).decrypt_key)
    @account_login.account_id = params[:id]
    render :layout => false
  end

  def show
    @account_login = AccountLogin.find params[:id]
    @div_id = 'login_detail_div_' + @account_login.id.to_s
    render :partial => 'show'
  end

  # Same as comment for 'new', this method is for an
  # AccountLogin for now.
  def create
    @account_login = AccountLogin.new(User.find(session[:user]).decrypt_key, params[:account_login])
    @account_login.created_by = session[:user]
    # See if a text description has been provided, or an example description.
    if @account_login.description.blank?
      @account_login.description = params[:account_login][:example_description]
    end
    if @account_login.save
      @account_login.encrypt_username
      @account_login.encrypt_password
      flash[:notice] = 'Login information saved and encrypted.'
    else
      flash[:error] = 'Unable to add login details.'
    end
    redirect_to :controller => 'accounts', :action => 'show', :id => @account_login.account_id
  end

  def edit
    @account_login = AccountLogin.find params[:id]
    dk = User.find(session[:user]).decrypt_key
    @account_login.decrypt_username(dk)
    @account_login.decrypt_password(dk)
    # We need to set up a div_id for our RHTML
    @div_id = "account_login_div_" + @account_login.id.to_s
    render :layout => false
  end

  def update
    dk = User.find(session[:user]).decrypt_key
    @account_login = AccountLogin.find params[:id]
    @account_login.update_attribute(:description, params[:account_login][:description])
    @account_login.update_attribute(:url, params[:account_login][:url])
    @account_login.decrypted_username = params[:account_login][:decrypted_username]
    @account_login.decrypted_password = params[:account_login][:decrypted_password]
    @account_login.encrypt_username(dk)
    @account_login.encrypt_password(dk)
    @account_login.reload
    @account_login.update_attribute :updated_by, session[:user]
    flash[:notice] = 'Login details updated.'
    redirect_to :controller => 'accounts', :action => 'show', :id => @account_login.account_id
  end

  def destroy
    @account_login = AccountLogin.find(params[:id])
    @account_login.destroy
    flash[:notice] = 'Login information deleted.'
    redirect_to :controller => 'accounts', :action => 'show', :id => @account_login.account_id
  end
end
