class IpAddressesController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post,
         :only => [:destroy, :create, :update, :assign_to_company,
                   :update_assigned_company, :unassign_company,
                   :assign_to_hardware, :update_assigned_hardware,
                   :unassign_hardware],
         :redirect_to => { :action => :list }

  def auto_complete_for_ip_address_address
    @search_phrase = params[:ip_address][:address].strip
    @ip_addresses = IpAddress.find :all, :conditions => ['address LIKE ?', "%#{@search_phrase}%"],
                                   :order => "INET_ATON(address)"
    if @ip_addresses.length < 20
      @resolve_ptr = true
    else
      @resolve_ptr = false
    end
    render :layout => false
  end

  def index
    @total_ips = IpAddress.count
    @unassigned_ips = IpAddress.unassigned_ips.length
    @ip_addresses = IpAddress.find_all_in_address_order
    @ip_networks = IpAddress.find_networks
  end

  def list
    if params[:order_by].blank?
      order_by = "INET_ATON(address)"
    else
      order_by = params[:order_by]
      # IP addresses need to be ordered specially, catch that event.
      if order_by == 'address'
        order_by = "INET_ATON(address)"
      end
    end
    if params[:order].blank?
      order = 'ASC' # the order to sort our result by
      @order = 'ASC' # the order to provide in the link on list.rhtml
    else
      order = params[:order]
      if order == 'ASC' then @order = 'DESC' else @order = 'ASC' end
    end
    @companies = Company.find :all, :order => 'name'
    if params[:ip]
      @start_value = params[:ip]
      if params[:company_id]
        # We have been called as ip_addresses/list/123.123.123?company_id=x
        conditions =  ["address LIKE ? AND company_id = ?", "#{@start_value}%", params[:company_id]]
        @total_ips = IpAddress.count(:conditions => conditions)
        @ip_addresses = IpAddress.paginate(:per_page => session[:list_limit], :page => params[:page],
                                           :conditions => conditions, :order => "#{order_by} #{order}")
      else
        # We have been called as ip_addresses/list/123.123.123
        conditions = ["address LIKE ?", "#{@start_value}%"]
        @total_ips = IpAddress.count(:conditions => conditions) 
        @ip_addresses = IpAddress.paginate(:per_page => session[:list_limit], :page => params[:page],
                                           :conditions => conditions, :order => "#{order_by} #{order}")
      end
    else
      if params[:company_id]
        # We have been called as ip_addresses/list?company_id=x
        conditions = ["company_id = ?", params[:company_id]]
        @total_ips = IpAddress.count(:conditions => conditions)
        @ip_addresses = IpAddress.paginate(:per_page => session[:list_limit], :page => params[:page],
                                           :conditions => conditions, :order => "#{order_by} #{order}")
      else
        # We have been called as ip_addresses/list
        @total_ips = IpAddress.count
        @ip_addresses = IpAddress.paginate(:per_page => session[:list_limit], :page => params[:page],
                                           :order => "#{order_by} #{order}")
      end
    end
  end

  def show
    @ip_address = IpAddress.find(params[:id])
  end

  def new
    @ip_address = IpAddress.new
    @companies = Company.find :all, :order => 'name'
  end

  def create
    # First check to see if we are assigning to a company
    if params[:ip_address][:no_company] == "1"
      company_id = nil
    else
      company_id = params[:ip_address][:company_id]
    end
    # IP can be added in several ways, check 'method' var
    case params[:ip_address][:method].to_i
    when 0
      flash[:error] = "No IP address adding method selected"
      logger.debug("DEBUG >>> #{flash[:error]}")
      @companies = Company.find :all, :order => 'name'
      render :action => 'new'
    when 1  # multiple IPs
      ips = []
      params[:ip_address][:address].each_line do |line|
        ips << {:address => line.strip, :company_id => company_id,
                :hardware_id => nil}
      end
    when 2 # a class C range
      # Sanitize the network input
      if params[:ip_address][:network].last == '.'
        network = params[:ip_address][:network]
        logger.debug("DEBUG >>> Network address ended with a full-stop - #{network}")
      else
        network = params[:ip_address][:network] + '.'
        logger.debug("DEBUG >>> Network address ended without a full-stop")
      end
      ips = []
      ip_range = (params[:ip_address][:start].to_i..params[:ip_address][:end].to_i)
      ip_range.each do |last_octet|
        ips << {:address => network + last_octet.to_s, :company_id => company_id}
      end
    else
      flash[:error] = "No IP address adding method selected"
      logger.debug("DEBUG >>> #{flash[:error]}")
      @companies = Company.find :all, :order => 'name'
      render :action => 'new'
    end
    if flash[:error].blank?
      begin 
        @ip_addresses = IpAddress.create!(ips)
        flash[:notice] = @ip_addresses.length.to_s + " IP addresses successfully created." unless @ip_addresses.length == 0
        redirect_to :action => 'list'
      rescue
        flash[:error] = 'Could not create IP addresses.'
        @ip_address = IpAddress.new params[:ip_address]
        @companies = Company.find :all, :order => 'name'
        render :action => 'new'
      end
    end
  end

  def edit
    @ip_address = IpAddress.find(params[:id])
    if @ip_address.company_id == nil
      @ip_address.no_company = true
    else
      @ip_address.no_company = false
    end
    if @ip_address.hardware_id == nil
      @ip_address.no_hardware = true
    else
      @ip_address.no_hardware = false
    end
    @companies = Company.find :all, :order => 'name'
    @hardware = Hardware.find :all, :order => 'name'
  end

  def update
    @ip_address = IpAddress.find(params[:id])
    # Manually assign all the parameters, as we have our :no_x methods to handle
    if params[:ip_address][:no_company] == '1'
      @ip_address.company_id = nil
    else
      @ip_address.company_id = params[:ip_address][:company_id]
    end
    if params[:ip_address][:no_hardware] == '1'
      @ip_address.hardware_id = nil
    else
      @ip_address.hardware_id = params[:ip_address][:hardware_id]
    end
    @ip_address.address = params[:ip_address][:address]
    if @ip_address.save
      flash[:notice] = 'IP address was successfully updated.'
      redirect_to :action => 'show', :id => @ip_address
    else
      flash[:error] = 'IP address could not be updated.'
      @companies = Company.find :all, :order => 'name'
      @hardware = Hardware.find :all, :order => 'name'
      render :action => 'edit'
    end
  end

  def destroy
    IpAddress.find(params[:id]).destroy
    redirect_to :back
  end

  def get_ptr
    div_id = "ptr_#{params[:id]}"
    render :update do |page|
      page << '<script type="text/javascript">'
      page.replace div_id,
                   :inline => %{<div id=#{div_id}>#{IpAddress.find(params[:id]).ptr}</div>}
      page.visual_effect :highlight, div_id
      page << '</script>'
    end
  end

  def show_assigned_company
    @ip_address = IpAddress.find(params[:id])
    render :layout => false
  end

  def assign_to_company
    @ip_address = IpAddress.find(params[:id])
    @companies = Company.find :all, :order => 'name'
    render :layout => false
  end

  def update_assigned_company
    @ip_address = IpAddress.find(params[:id])
    @ip_address.update_attributes(params[:ip_address])
    redirect_to :action => 'show_assigned_company', :id => @ip_address
  end

  def unassign_company
    @ip_address = IpAddress.find(params[:id])
    @ip_address.update_attribute(:company_id, nil)
    redirect_to :action => 'show_assigned_company', :id => @ip_address
  end

  def show_assigned_hardware
    @ip_address = IpAddress.find params[:id]
    render :layout => false
  end

  def assign_to_hardware
    @ip_address = IpAddress.find params[:id]
    @hardware = Hardware.find :all, :order => 'name'
    render :layout => false
  end

  def update_assigned_hardware
    @ip_address = IpAddress.find params[:id]
    @ip_address.update_attributes(params[:ip_address])
    redirect_to :action => 'show_assigned_hardware', :id => @ip_address
  end

  def unassign_hardware
    @ip_address = IpAddress.find params[:id]
    @ip_address.update_attribute(:hardware_id, nil)
    redirect_to :action => 'show_assigned_hardware', :id => @ip_address
  end

  # RJS action used in ip_addresses/new
  def options_for_method
    @method = params[:id].to_i
    # Render the RJS
    render :update do |page|
      page << '<script type="text/javascript">'
      page.replace 'method_options', :partial => 'method_options'
      page.visual_effect :highlight, 'method_options'
      page << '</script>'
    end
  end

  def available_ip_addresses
    # Method needs to be called with params[:id] set as a company ID and currently used IP
    # addresses if called from accounts/edit
    unless params[:hardware_id].blank?
      @ip_addresses = Hardware.find(params[:hardware_id]).ip_addresses.collect {|ip| ip.id}
    else
      @ip_addresses = nil
    end
    @available_ips_for_select = IpAddress.available_ips_for_select(params[:id], @ip_addresses)
    @ip_address = IpAddress.new
    render :update do |page|
      page << '<script type="text/javascript">'
      page.replace 'available_ips', :partial => 'available_ip_addresses'
      page.visual_effect :highlight, 'available_ips'
      page << '</script>'
    end
  end
end
