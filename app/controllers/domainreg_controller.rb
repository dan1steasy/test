class DomainregController < ApplicationController

  auto_complete_for :domain_registration, :domain_name

  def index
    @total_domains = DomainRegistration.count
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :index }

  def list
    # This list method should be able to sort domains based on renewal dates.
  end

  def show
  end

  def auto_complete_for_domain_registration_domain_name
    @search_phrase = params[:domain_registration][:domain_name]
    @domain_registrations = DomainRegistration.find :all, :order => 'domain_name, tld',
                                                     :conditions => ["domain_name LIKE ?",
                                                                     "%#{@search_phrase}%"]
    render :layout => false
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def registrars
    # To save typing 'domainreg' in our render calls, set a variable
    d = params[:controller] + '/'
    case params[:r_action]
    when nil, '', 'index', 'list'
      @registrar_pages, @registrars = paginate :registrars, :per_page => 15, :order => 'name'
      render :template => d + 'registrars_list'
    when 'show'
      @registrar = Registrar.find params[:id]
      # Decrypt the username & password
      @registrar.decrypt_username(User.find(session[:user]).decrypt_key)
      @registrar.decrypt_password(User.find(session[:user]).decrypt_key)
      render :template => d + 'registrars_show'
    when 'new'
      @registrar = Registrar.new
      render :template => d + 'registrars_new'
    when 'create'
      @registrar = Registrar.new params[:registrar]
      if @registrar.save
        # Encrypt the login details
        @registrar.encrypt_username(User.find(session[:user]).decrypt_key)
        @registrar.encrypt_password(User.find(session[:user]).decrypt_key)
        flash[:notice] = 'Registrar was successfully created.'
        redirect_to :action => 'registrars', :r_action => 'show', :id => @registrar.id
      else
        flash[:error] = 'Registrar could not be created.'
        render :template => d + 'registrars_new'
      end
    when 'edit'
      @registrar = Registrar.find params[:id]
      # Decrypt the username & password
      @registrar.decrypt_username(User.find(session[:user]).decrypt_key)
      @registrar.decrypt_password(User.find(session[:user]).decrypt_key)
      render :template => d + 'registrars_edit'
    when 'update'
      @registrar = Registrar.find params[:id]
      if @registrar.update_attributes params[:registrar]
        # Encrypt the login details.
        @registrar.encrypt_username(User.find(session[:user]).decrypt_key)
        @registrar.encrypt_password(User.find(session[:user]).decrypt_key)
        @registrar.reload
        flash[:notice] = 'Registrar was successfully updated.'
        redirect_to :action => 'registrars', :r_action => 'show', :id => @registrar.id
      end
    when 'destroy'
      Registrar.find(params[:id]).destroy
      flash[:notice] = "Registrar deleted"
      redirect_to :action => 'registrars', :r_action => 'list'
    end
  end
end
