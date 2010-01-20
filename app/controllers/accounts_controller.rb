class AccountsController < ApplicationController
  require_dependency 'note'
  require_dependency 'login_detail'

  def index
    @total_accounts = Account.count
    @accounts = Account.find :all, :order => 'domain_name, host_name' unless @total_accounts > 500
    @account_types = AccountType.find :all, :order => 'name'
    @hardware_types = HardwareType.find :all, :order => 'name'
    #@companies = Company.find :all, :order => 'name'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:destroy, :create, :update, :destroy_ssl],
         :redirect_to => {:action => :list}

  def list
    # Set up ordering parameters (order_by & order)
    if params[:order_by].blank?
      order_by = "id"
    else
      order_by = params[:order_by]
    end
    if params[:order].blank?
      order = 'ASC'
      @order = 'ASC'
    else
      order = params[:order]
      if order == 'ASC' then @order = 'DESC' else @order = 'ASC' end
    end

    if params[:id]
      @search_phrase = params[:id]
      @total_accounts = Account.count :conditions => ["domain_name LIKE ?", "#{@search_phrase}%"]
      @accounts = Account.paginate(:order => "#{order_by} #{order}",
                                   :conditions => ["domain_name LIKE ?", "#{@search_phrase}%"],
                                   :per_page => session[:list_limit], :page => params[:page])
    else
      @total_accounts = Account.count
      @accounts = Account.paginate(:order => "#{order_by} #{order}",
                                   :per_page => session[:list_limit], :page => params[:page])
    end
  end

  def list_deactivated
    # Set up ordering parameters (order_by & order)
    if params[:order_by].blank?
      order_by = "id"
    else
      order_by = params[:order_by]
    end
    if params[:order].blank?
      order = 'ASC'
      @order = 'ASC'
    else
      order = params[:order]
      if order == 'ASC' then @order = 'DESC' else @order = 'ASC' end
    end

    @total_accounts = Account.count :conditions => ["is_active = ?", false]
    @accounts = Account.paginate(:order => "#{order_by} #{order}", :conditions => ["is_active = ?", false],
                                 :per_page => session[:list_limit], :page => params[:page])
  end

  def list_by_company
    @accounts = Account.find_all_by_company_id params[:id], :order => 'domain_name, host_name'
    render :update do |page|
      page.replace("account_listing", :partial => 'listing')
      page.visual_effect :highlight, 'account_listing'
    end
  end

  def list_by_type
    # Set up ordering parameters (order_by & order)
    if params[:order_by].blank?
      order_by = "id"
    else
      order_by = params[:order_by]
    end
    if params[:order].blank?
      order = 'ASC'
      @order = 'ASC'
    else
      order = params[:order]
      if order == 'ASC' then @order = 'DESC' else @order = 'ASC' end
    end
    account_type_id = params[:account_type_id] || params[:account_type][:id]
    begin
      @account_type = AccountType.find account_type_id
    rescue
      redirect_to :controller => :accounts
    end
    @total_accounts = Account.count(:conditions => ['account_type_id = ?', account_type_id])
    @accounts = Account.paginate(:order => "#{order_by} #{order}",
                                 :per_page => session[:list_limit], :page => params[:page],
                                 :conditions => ['account_type_id = ?', account_type_id])
  end

  def list_by_hardware_type
    # Set up ordering parameters (order_by & order)
    if params[:order_by].blank?
      order_by = "id"
    else
      order_by = params[:order_by]
    end
    if params[:order].blank?
      order = 'ASC'
      @order = 'ASC'
    else
      order = params[:order]
      if order == 'ASC' then @order = 'DESC' else @order = 'ASC' end
    end
    hardware_type_id = params[:hardware_type_id] || params[:hardware_type][:id]
    begin
      @hardware_type = HardwareType.find hardware_type_id
    rescue
      redirect_to :controller => :accounts
    end
    @total_hardware = Hardware.count(:conditions => ['hardware_type_id = ?', hardware_type_id])
    @hardware = Hardware.paginate(:order => "#{order_by} #{order}", :per_page => session[:list_limit],
                                  :conditions => ['hardware_type_id = ?', hardware_type_id],
                                  :page => params[:page])
  end

  def search
    if params[:account] != nil
      if params[:account][:fqdn]
        @search_phrase = params[:account][:fqdn].strip
        conditions = ["CONCAT(host_name, '.', domain_name) LIKE ?", "%#{@search_phrase}%"]
        search_type = 'account'
      elsif params[:account][:mac_address]
        @search_phrase = params[:account][:mac_address].strip
        conditions = ["mac_address LIKE ?", "%#{@search_phrase}%"]
        search_type = 'hardware'
      elsif params[:account][:date_range]
      elsif params[:account][:serial_number]
        @search_phrase = params[:account][:serial_number].strip
        conditions = ["serial_number LIKE ?", "%#{@search_phrase}%"]
        search_type = 'hardware'
      end
    end
    if search_type == 'account'
      @accounts = Account.paginate(:order => 'domain_name, host_name', :page => params[:page],
                                   :per_page => session[:list_limit], :conditions => conditions)
      if @accounts.length == 1
        flash[:notice] = "<strong>#{@search_phrase}</strong> matched only one account - viewing #{@accounts[0].fqdn} now."
        redirect_to account_url(:fqdn => @accounts[0].fqdn)
      end
    elsif search_type == 'hardware'
      @hardware = Hardware.paginate(:order => 'name', :per_page => session[:list_limit],
                                    :conditions => conditions, :page => params[:page])
      if @hardware.length == 1
        flash[:notice] = "<strong>#{@search_phrase}</strong> matched only one account - viewing #{@hardware[0].name} now."
        redirect_to account_url(:fqdn => @hardware[0].name)
      end
    end
  end

  def show
    if request.post?
      redirect_to :action => 'show', :id => params[:account][:id] and return
    else
      begin
        @account = Account.find(params[:id], :include => :company)
        get_objects_for_account_show
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "No account found with that ID"
        redirect_to :action => 'list'
      end
    end
  end

  def show_fqdn
    begin
      @account = Account.find_by_fqdn(params[:fqdn])
      get_objects_for_account_show
      render :action => 'show'
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Account details no longer exist for #{params[:fqdn]} (orphaned hardware)" +
                      " - viewing hardware details."
      redirect_to hardware_url(:name => params[:fqdn])
    rescue
      flash[:error] = "No account found under that name"
      redirect_to :action => 'list'
    end
  end

  def auto_complete_for_account_fqdn
    @search_phrase = params[:account][:fqdn]
    conditions = ["CONCAT(host_name, '.', domain_name) LIKE ? AND is_active = TRUE", "%#{@search_phrase}%"]
    logger.debug("DEBUG >>> Search conditions: #{conditions.flatten}")
    @accounts = Account.find :all, :order => 'domain_name, host_name',
                             :conditions => conditions
    render :layout => false
  end

  def auto_complete_for_hardware_mac_address
    # stub
  end

  def new
    @account = Account.new
    if params[:id]
      @account.company_id = params[:id]
    end
  end

  def create
    # We'll need user and decrypted key values a couple of times, store them in variables
    user = session[:user]
    dk = User.find(user).decrypt_key
    # We can end up with lots of flash messages here, set up some empty strings
    notice, error = '', ''
    @account = Account.new(params[:account])
    logger.debug("DEBUG >> account_type_id: #{@account.account_type_id}")
    @account.created_by = user
    # Add our quotas to the account
    @disk_quota = DiskQuota.new(params[:disk_quota])
    @bandwidth_quota = BandwidthQuota.new(params[:bandwidth_quota])
    @account.disk_quota = @disk_quota
    @account.bandwidth_quota = @bandwidth_quota
    # Set up other objects if necessary
    @licence_type = LicenceType.find(params[:licence_type][:id]) unless params[:licence_type][:id].blank?
    @hardware = Hardware.new(params[:hardware]) unless params[:hardware].blank?
    @free_cabinet_bay_list = @hardware.cabinet.available_bay_list(params[:u_size].to_i) unless @hardware.blank?
    # CREATE ONLY ON FAIL: @account_type = @account.account_type # We need the account type if we have to get redirected back to 'new'
    @ip_addresses = IpAddress.find(params[:ip_address_ids].collect {|id| id.to_i}) unless params[:ip_address_ids].blank?
    @available_ips_for_select = IpAddress.available_ips_for_select params[:account][:company_id] unless @hardware.blank?
    unless (params[:account_login][:decrypted_username].blank?) and (params[:account_login][:decrypted_password].blank?)
      logger.debug("DEBUG >> A username or password for a login detail has been provided")
      logger.debug("DEBUG >> Creating new AccountLogin object")
      @account_login = AccountLogin.new(dk, params[:account_login])
    end
    unless params[:account_note][:decrypted_note].blank?
      logger.debug("DEBUG >> A note has been provided")
      logger.debug("DEBUG >> Creating new AccountNote object")
      @account_note = AccountNote.new(dk, params[:account_note])
    end
    # Objects are now setup, start a transaction
    logger.debug("DEBUG >> Starting transaction...")
    Account.transaction do
      # Assign a licence if necessary
      logger.debug("DEBUG >> Checking for provision of licence...")
      if @licence_type
        # Check to see if we have a licence
        logger.debug("DEBUG >> Checking for available licences...")
        if @licence_type.available_licences > 0
          # Yes we have, mark it as in_use and assign it to the account
          @licence = @licence_type.next_available_licence
          @licence.in_use = true
          @account.licences << @licence
          logger.debug("DEBUG >> Saving licence")
          @licence.save!
        else
          error += "No #{@licence_type.name} licences left!"
        end
      end
      # Add an AccountLogin if necessary
      logger.debug("DEBUG >> Checking if we have a login...")
      if @account_login
        logger.debug("DEBUG >> Creating login")
        @account_login.account_id = @account.id
        @account_login.created_by = user
        # See if a text description has been provided, or an example description.
        if @account_login.description.blank?
          @account_login.description = params[:account_login][:example_description]
        end
        if @account_login.save!
          logger.debug("DEBUG >> Login detail saved")
          @account_login.encrypt_username
          logger.debug("DEBUG >> Login detail username encrypted")
          @account_login.encrypt_password
          logger.debug("DEBUG >> Login detail password encrypted")
          @account_login.reload
          @account.account_logins << @account_login
        end
      end
      # Add an AccountNote if necessary
      if @account_note
        logger.debug("DEBUG >> Creating note")
        @account_note.account_id = @account.id
        @account_note.created_by = user
        if @account_note.save!
          logger.debug("DEBUG >> Note saved")
          @account_note.encrypt_note
          logger.debug("DEBUG >> Note encrypted")
          @account_note.reload
          @account.account_notes << @account_note
        end
      end
      # If we have been sent hardware info, create a new hardware object
      if @hardware
        logger.debug("DEBUG >> Creating hardware")
        @hardware.created_by = user
        @hardware.name = @account.fqdn
        @hardware.company_id = @account.company_id
        if @hardware.save!
          # Assign IP addresses
          logger.debug("DEBUG >> Assigning IPs")
          if @ip_addresses
            @ip_addresses.each do |ip|
              ip.company_id = @account.company_id
              ip.hardware_id = @hardware.id
              ip.save!
            end
          end
          # Assign the hardware_id to the account
          @account.update_attribute(:hardware_id, @hardware.id)
        end
      end
      logger.debug("DEBUG >> saving account...")
      @account.save!
    end
    logger.debug("DEBUG >> Transaction finished.")
    # If we've made it here, everything has been saved!
    flash[:notice] = "<strong>#{@account.fqdn}</strong> successfully created."
    redirect_to account_url(:fqdn => @account.fqdn)
    
    rescue ActiveRecord::RecordInvalid => e
      logger.debug("DEBUG >> Rescued an ActiveRecord::RecordInvalid error: #{e}")
      @account.valid?
      unless @account_login.blank?
        logger.debug("DEBUG >> running validations on @account_login")
        @account_login.valid? 
      end
      unless @account_note.blank?
        logger.debug("DEBUG >> running validations on @account_note")
        @account_note.valid?
      end
      unless @hardware.blank?
        logger.debug("DEBUG >> running validations on @hardware")
        @hardware.valid?
      end
      unless @licence.blank?
        logger.debug("DEBUG >> running validations on @licence")
        @licence.valid?
      end
      # Load up the account_type for use in templates.
      @account_type = AccountType.find @account.account_type_id unless @account.account_type.blank?
      flash[:error] = "Could not create account!"
      render :action => 'new'
  end

  def edit
    @account = Account.find(params[:id])
    @account_type = @account.account_type
    @bandwidth_quota = @account.bandwidth_quota
    @disk_quota = @account.disk_quota
    if @account_type.requires_hardware
      logger.debug("DEBUG >>> account type requires hardware")
      @hardware = Hardware.find_by_name @account.fqdn
      @free_cabinet_bay_list = @hardware.cabinet.available_bay_list(params[:u_size].to_i)
      @ip_addresses = @hardware.ip_addresses
      logger.debug("DEBUG >>> calling available_ips_for_select with Company ID #{@account.company_id}")
      @available_ips_for_select = IpAddress.available_ips_for_select(@account.company_id, @hardware.ip_addresses.collect {|ip| ip.id})
    end
  end

  def update
    @account = Account.find(params[:id])
    @hardware = Hardware.find_by_name(@account.fqdn) unless params[:hardware].blank?
    @account.updated_by = session[:user]
    if @account.update_attributes(params[:account])
      if @account.bandwidth_quota.blank?
        @account.create_bandwidth_quota(params[:bandwidth_quota]) unless params[:bandwidth_quota][:value].blank?
      else
        @account.bandwidth_quota.update_attributes(params[:bandwidth_quota]) unless params[:bandwidth_quota][:value].blank?
      end
      if @account.disk_quota.blank?
        @account.create_disk_quota(params[:disk_quota]) unless params[:disk_quota][:value].blank?
      else
        @account.disk_quota.update_attributes(params[:disk_quota]) unless params[:disk_quota][:value].blank?
      end
      # Handle any updates for hardware if it's required.
      if @hardware
        logger.debug("DEBUG >>> We have hardware to update...")
        @account.reload
        @hardware.updated_by = session[:user]
        @hardware.name = @account.fqdn
        @hardware.company_id = @account.company_id
        @hardware.update_attributes!(params[:hardware])
        # We need to modify IP addresses - we need to NULLify any old IPs that aren't selected
        @old_ip_addresses = @hardware.ip_addresses
        # NULLify all old_ip_addresses
        unless @old_ip_addresses.blank?
          IpAddress.update_all("hardware_id = NULL", "id IN(#{@old_ip_addresses.map {|ip| ip.id}.join(',')})")
        end
        # Now add in any new ones.
        unless params[:ip_address_ids].blank?
          in_values = params[:ip_address_ids].join(',')
          IpAddress.update_all("hardware_id = #{@hardware.id}", "id IN(#{in_values})")
        end
      end
      flash[:notice] = 'Account was successfully updated.'
      redirect_to :action => 'show', :id => @account
    else
      render :action => 'edit'
    end
  end

  def destroy
    @account = Account.find(params[:id])
    deactivated_date = Time.now.to_date
    if @account.is_hardware?
      @hardware = Hardware.find_by_name(@account.fqdn)
      if @account.is_active
        @hardware.update_attributes(:is_active => false, :deactivated_on => deactivated_date)
        @account.update_attributes(:is_active => false, :deactivated_on => deactivated_date)
        flash[:notice] = 'Account and hardware marked as deactivated.'
        redirect_url = account_url(:fqdn => @account.fqdn)
      else
        # Account already deactivated, destroy it
        @hardware.destroy
        @account.reload
        @account.destroy
        flash[:notice] = 'Account and hardware deleted.'
        redirect_url = {:controller => 'companies', :action => 'show', :id => @account.company}
      end
    else
      if @account.is_active
        @account.update_attributes(:is_active => false, :deactivated_on => deactivated_date)
        flash[:notice] = @account.fqdn + ' marked as deactivated.'
        redirect_url = account_url(:fqdn => @account.fqdn)
      else
        # Account is already deactivated, destroy it
        @account.destroy
        flash[:notice] = @account.fqdn + ' deleted.'
        redirect_url = {:controller => 'companies', :action => 'show', :id => @account.company}
      end
    end
    redirect_to redirect_url
  end

  def activate
    @account = Account.find params[:id]
    @account.is_active = true
    if @account.save
      flash[:notice] = "Account reactivated"
    else
      flash[:error] = "Could not reactivate account!"
    end
    redirect_to account_url(:fqdn => @account.fqdn)
  end

  # RJS action (used in accounts/new)
  def options_for_type
    @account_type = AccountType.find(params[:id]) unless params[:id] =~ /[^0-9]/
    # Set up a hardware object if one doesn't exist
    @hardware = Hardware.new(:u_size => nil) unless @hardware
    @ip_address = IpAddress.new unless @ip_address
    @available_ips_for_select = IpAddress.available_ips_for_select params[:company_id]
    # If we've been provided with an account_id, load up the @account object
    @account = Account.find(params[:account_id]) unless params[:account_id].blank?
    # Render our RJS stuff here (not big enough to need own file)
    render :update do |page|
      page << '<script type="text/javascript">'
      page.replace 'relevant_details', :partial => "relevant_details" 
      page.visual_effect :highlight, 'relevant_details'
      page << '</script>'
    end
  end

  # Method to return the nameservers for an account, using the
  # Whois library methods. Should be called by XHR method.
  def get_nameservers
    @account = Account.find(params[:id])
    begin
      @nameservers = @account.nameservers
      # If there are no nameservers/WHOIS details, this will be blank
      if @nameservers.blank?
        render :inline => "<em>No nameservers listed, or no WHOIS data<br />available for #{@account.domain_name}</em>"
      else
        render :inline => @nameservers.join(' ')
      end
    rescue 
      # Render an error message
      render :inline => "<em>#{$!}</em>"
    end
  end

  def assign_licence
    if request.xhr?
      @account = Account.find params[:id]
      @licence_types = LicenceType.find :all, :order => 'name'
      render :layout => false
    elsif request.post?
      @account = Account.find params[:id]
      # See if they provided a new licence value, or if we are assigning from stock.
      if params[:licence][:value].blank?
        # Try to assign from stock
        @licence_type = LicenceType.find params[:licence_type][:id]
        # Check to see if we have a licence
        if @licence_type.available_licences > 0
          # Yes we have, mark it as in_use and assign it to the account
          @licence = @licence_type.next_available_licence
          @licence.in_use = true
          @account.licences << @licence
          if @account.save
            flash[:notice] = "#{@licence_type.name} licence successfully assigned to #{@account.fqdn}"
          else
            flash[:error] = "Licence could not be assigned to account."
          end
        else
          flash[:error] = "No #{@licence_type.name} licences left!"
        end
      else
        # They are providing a new licence, first check if it has an expiry date.
        if params[:licence][:no_expiry] == '0'
          expires_on = params[:licence][:expires_on]
        else
          expires_on = nil
        end
        @licence = Licence.new params[:licence]
        @licence.licence_type_id = params[:licence_type][:id]
        @licence.in_use = true
        if @licence.save
          @account.licences << @licence
          if @account.save
            flash[:notice] = "#{@licence.licence_type.name} licence successfully saved and assigned to #{@account.fqdn}"
          else
            flash[:error] = "Licence created, but could not be assigned to account."
          end
        else
          flash[:error] = "Licence could not be created."
        end
      end
      redirect_to :back
    end
  end

  # Method used to manage SSL certificates. Decides whether to view
  # or update based on request
  def show_ssl
    @account = Account.find params[:id]
  end

  def new_ssl
    @account = Account.find params[:id]
    @ssl = Ssl.new
  end

  def create_ssl
    @account = Account.find params[:id]
    @ssl = @account.create_ssl(params[:ssl])
    if @ssl.valid?
      flash[:notice] = "SSL details for #{@account.fqdn} saved."
      redirect_to :action => :show_ssl, :id => @account
    else
      flash[:error] = "SSL details could not be saved!"
      render :action => :new_ssl
    end
  end

  def edit_ssl
    @account = Account.find params[:id]
    @ssl = @account.ssl
  end

  def update_ssl
    @account = Account.find params[:id]
    @ssl = @account.ssl
    if @ssl.update_attributes(params[:ssl])
      flash[:notice] = "SSL details updated."
      redirect_to :action => :show_ssl, :id => @account
    else
      flash[:error] = "SSL details could not be updated!"
      render :action => 'edit_ssl'
    end
  end

  def destroy_ssl
    @account = Account.find params[:id]
    @account.ssl.destroy
    flash[:notice] = "SSL details removed."
    redirect_to account_url(:fqdn => @account.fqdn)
  end

  private
  def get_objects_for_account_show
    logger.debug("DEBUG >> @account = #{@account.to_yaml}")
    # We need a @company global for use in a partial
    @company = @account.company
    # We need a @contacts global for use in a partial
    @contacts = @account.company.contacts
    @ip_addresses = @account.ip_addresses(true)
    # We may need to load up a hardware object
    if @account.account_type.requires_hardware
      @hardware = Hardware.find_by_name(@account.fqdn)
      @accounts = @hardware.accounts
      @hosted_account_number = @hardware.accounts.size - 1 # hardware always has itself listed as a
                                                           # hosted account.
    end
    # We need to create different messages for the delete action,
    # depending on whether our account is hardware.
    if @account.is_hardware?
      if @account.is_active
        @delete_text = " - mark this account <strong>and the hardware associated with it</strong> as deactivated/cancelled"
        @delete_confirm = "Are you sure you want to deactivate the account '#{@account.fqdn}' and the associated hardware?"
      else
        @delete_text = " - remove this account <strong>and the hardware associated with it</strong>" +
                       " from the database"
        @delete_confirm = "Are you sure you want to remove the account '#{@account.fqdn}'" +
                          " and the associated hardware?"
      end
    else
      if @account.is_active
        @delete_text = " - mark this account as deactivated/cancelled"
        @delete_confirm = "Are you sure you want to deactivate the account '#{@account.fqdn}'?"
      else
        @delete_text = " - remove this account from the database"
        @delete_confirm = "Are you sure you want to remove the account '#{@account.fqdn}'?"
      end
    end
  end

end
