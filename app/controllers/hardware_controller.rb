class HardwareController < ApplicationController

  def new
    @hardware = Hardware.new(:u_size => nil)
    @companies = Company.find :all, :order => 'name'
    @ip_address = IpAddress.new unless @ip_address
    @available_ips_for_select = IpAddress.available_ips_for_select
  end

  def create
    @hardware = Hardware.new(params[:hardware])
    @hardware.created_by = session[:user]
    logger.debug("DEBUG >> cab_bay: #{@hardware.starting_cabinet_bay}")
    if @hardware.save
      @ip_addresses = IpAddress.find(params[:ip_address_ids].collect {|id| id.to_i}) unless params[:ip_address_ids].blank?
      if @ip_addresses
        @ip_addresses.each do |ip|
          ip.company_id = @hardware.company_id
          ip.hardware_id = @hardware.id
          ip.save
        end
      end
      redirect_to :action => :show, :id => @hardware
    else
      @available_ips_for_select = IpAddress.available_ips_for_select @hardware.company_id
      @companies = Company.find :all, :order => 'name'
      @free_cabinet_bay_list = @hardware.cabinet.available_bay_list(@hardware.u_size)
      render :action => 'new'
    end
  end

  def show
    @hardware = Hardware.find params[:id]
  end

  def show_name
    @hardware = Hardware.find_by_name(params[:name])
    render :action => 'show'
  end

  def asset_values
    # Set up ordering parameters (order_by and order)
    if params[:order_by].blank?
      order_by = "name" # order by name by default
    else
      order_by = params[:order_by]
    end
    if params[:order].blank?
      order = "ASC"
      @order = "ASC"
    else
      order = params[:order]
      if order == 'ASC' then @order = 'DESC' else @order = 'ASC' end
    end
    if params[:not_tagged].blank?
      @not_tagged = false
      conditions_array = ['asset_tag <> ? OR asset_tag <> NULL', '']
    else
      @not_tagged = true
      conditions_array = ['asset_tag IS NULL OR asset_tag = ?', '']
    end
    @total_hardware = Hardware.count(:conditions => conditions_array)
    @total_value = Hardware.sum(:asset_value, :conditions => conditions_array)
    @hardware = Hardware.paginate(:order => "#{order_by} #{order}", :conditions => conditions_array,
                                  :per_page => session[:list_limit], :page => params[:page])
  end

  def edit
    @hardware = Hardware.find params[:id]
  end

  def update
    @hardware = Hardware.find params[:id]
  end

  def destroy
    begin
      @hardware = Hardware.find(params[:id])
      deactivated_date = Time.now.to_date
      if @hardware.is_active
        @hardware.update_attributes(:is_active => false, :deactivated_on => deactivated_date)
        flash[:notice] = 'Hardware deactivated'
      else
        @hardware.destroy
        flash[:notice] = 'Hardware deleted'
      end
      redirect_to :controller => :dc, :action => :show, :id => @hardware.cabinet.datacentre
    rescue
      flash[:error] = $!
      redirect_to :back
    end
  end
end
