class LicencesController < ApplicationController

  in_place_edit_for :licence, :value

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post,
         :only => [:destroy, :create, :update, :assign, :update_assign, :unassign],
         :redirect_to => { :action => :list }

  def auto_complete_for_licence_value
    @search_phrase = params[:licence][:value]
    @licences = Licence.find :all, :conditions => ["value LIKE ?", "%#{@search_phrase}%"],
                             :order => :value
    render :layout => false
  end

  def index
    @licence_types = LicenceType.find :all, :order => 'name'
  end

  def list
    if request.post?
      id = params[:licence_type][:id]
      redirect_to :action => 'list', :id => id
    else
      begin
        @licence_type = LicenceType.find(params[:id])
        @total_licences = @licence_type.licences.count
        # Get the licenses, ordered by params
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
        @licences = Licence.paginate(:per_page => session[:list_limit],
                                     :conditions => "licence_type_id = #{@licence_type.id}",
                                     :order => "#{order_by} #{order}", :page => params[:page])
      rescue
        flash[:error] = $!
        redirect_to :controller => 'licences'
      end
    end
  end

  def show
    @licence = Licence.find(params[:id])
  end

  def new
    @licence_types = LicenceType.find :all, :order => 'name'
    @licence = Licence.new
    if params[:id]
      @licence.licence_type_id = params[:id]
    end
  end

  def create
    # First check if the no_expiry has been ticked.
    if params[:licence][:no_expiry] == '0'
      logger.debug("DEBUG >>> 'No expiry' not checked.")
      expires_on = params[:licence][:expires_on]
    else
      logger.debug("DEBUG >>> 'No expiry' checked.")
      expires_on = nil
    end
    # We can accept multiple licences here.
    licences = []
    if params[:licence][:multiple] == '0'
      logger.debug("DEBUG >> 'Multiple licences' not checked, single licence provided")
      @licence = Licence.new params[:licence]
      if @licence.save
        flash[:notice] = "Licence successfully added."
        redirect_to :action => 'list', :id => @licence.licence_type_id
      else
        # We need @licence_types in new.rhtml
        @licence_types = LicenceType.find :all, :order => 'name'
        flash[:error] = "Could not add licence."
        render :action => 'new'
      end
    else
      logger.debug("DEBUG >>> 'Multiple licences' checked")
      params[:licence][:value].each_line do |line|
        logger.debug("DEBUG >>> Licence provided: #{line}")
        licences << {:licence_type_id => params[:licence][:licence_type_id],
                     :value => line.strip, :expires_on => expires_on,
                     :in_use => false, :account_id => nil}
      end
      @licences = Licence.create(licences)
      flash[:notice] = @licences.length.to_s + " licences successfully added." unless @licences.length == 0
      redirect_to :action => 'list',
                  :id => params[:licence][:licence_type_id]
    end
  end

  def edit
    @licence_types = LicenceType.find :all, :order => 'name'
    @licence = Licence.find params[:id]
    # We need to set no_expiry accessor to nil if expires_on is null, to
    # make sure our checkbox is ticked.
    if @licence.expires_on == nil
      @licence.no_expiry = true
    end
  end

  def update
    @licence = Licence.find(params[:id])
    if @licence.update_attributes(params[:licence])
      flash[:notice] = 'Licence was successfully updated.'
      redirect_to :action => 'list', :id => @licence.licence_type_id
    else
      # We need to get licence_types before rendering 'edit'
      @licence_types = LicenceType.find :all, :order => 'name'
    end
  end

  def destroy
    @licence = Licence.find(params[:id])
    @licence.destroy
    flash[:notice] = 'Licence deleted.'
    redirect_to :action => :list, :id => @licence.licence_type_id
  end

  def show_assigned
    @licence = Licence.find params[:id]
    render :layout => false
  end

  def assign
    @licence = Licence.find params[:id]
    @accounts = Account.find :all, :order => 'domain_name, host_name'
    render :layout => false
  end

  def update_assign
    @licence = Licence.find params[:id]
    @licence.update_attributes(params[:licence])
    # Mark this licence as in_use
    @licence.update_attribute(:in_use, true)
    redirect_to :action => 'show_assigned', :id => @licence
  end

  def unassign
    @licence = Licence.find params[:id]
    @licence.in_use = false
    @licence.account_id = nil
    @licence.save
    redirect_to :action => 'show_assigned', :id => @licence
  end

  def availability_check
    if params[:id] != "CHOOSE LICENCE TYPE..."
      @available_licences = Licence.count(:conditions => ["in_use = false and licence_type_id = ?", params[:id]])
    else
      @available_licences = nil
    end
    render :layout => false
  end
end
