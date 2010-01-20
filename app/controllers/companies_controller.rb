class CompaniesController < ApplicationController

  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  require_dependency 'note'

  Company.content_columns.each do |column|
    in_place_edit_with_update_for :company, column.name
  end

  # Manually write set_company_postcode to use validations
  def set_company_postcode
    @company = Company.find(params[:id])
    old_postcode = @company.postcode
    @company.postcode = params[:value]
    @company.update_attribute('updated_by', session[:user])
    if @company.save
      render :update do |page|
        page.replace("company_postcode_#{params[:id]}_in_place_editor",
                     in_place_editor_field(:company, :postcode, {}, {:rows => 1}))
      end
    else
      # Grab the error message to display in a JS alert
      err_msg = @company.errors[:postcode]
      @company.postcode = old_postcode
      @company.save
      render :update do |page|
        page.replace("company_postcode_#{params[:id]}_in_place_editor",
                     in_place_editor_field(:company, :postcode, {:value => old_postcode}, {:rows => 1}))
        page.call("alert", "Supplied postcode " + err_msg + "\nReverted to original value.")
      end
    end
  end

  def auto_complete_for_company_name
    @search_phrase = params[:company][:name].strip
    @companies = Company.find :all, :conditions => ["name LIKE ?", "%#{@search_phrase}%"],
                              :order => :name
    render :layout => false
  end

  def auto_complete_for_company_postcode
    @search_phrase = params[:company][:postcode].strip
    @companies = Company.find :all, :conditions => ["postcode LIKE ?", "%#{@search_phrase}%"],
                              :order => :postcode
    render :layout => false
  end

  def index
    @total_companies = Company.count
    @companies = Company.find :all, :order => :name unless @total_companies > 500
  end

  def list
    if params[:id]
      @search_phrase = params[:id]
      # Assemble conditions array that will be used in our find and paginate calls
      conditions = ["name LIKE ?", "#{@search_phrase}%"]
      @total_companies = Company.count :conditions => conditions
      @companies = Company.paginate(:order => :name, :conditions => conditions,
                                    :per_page => session[:list_limit], :page => params[:page])
    else
      @total_companies = Company.count
      @companies = Company.paginate(:order => :name, :per_page => session[:list_limit],
                                    :page => params[:page])
    end
  end

  def show
    if request.post?
      redirect_to :action => 'show', :id => params[:company][:id]
    else
      begin
        @company = Company.find(params[:id], :include => [:contacts, :accounts])
        # We need the contacts and the accounts associated with this company.
        @contacts = @company.contacts
        @accounts = @company.accounts
        # Get the relevant notes for this company
        if User.find(session[:user]).is_in_finance
          @company_notes = @company.company_notes
        else
          @company_notes = @company.company_notes.find(:all, :conditions => ['is_financial = ?', false])
        end
      rescue
        flash[:error] = $!
        redirect_to :action => 'list'
      end
    end
  end

  def search
    if params[:company] != nil
      if params[:company][:name] 
        logger.debug("DEBUG >> Searching on company 'name'")
        @search_field = 'name'
        @search_phrase = params[:company][:name].strip
      elsif params[:company][:postcode]
        logger.debug("DEBUG >> Searching on company 'postcode'")
        @search_field = 'postcode'
        @search_phrase = params[:company][:postcode].strip
      end
    end
    if params[:company_number] != nil
      logger.debug("DEBUG >> Searching on company 'phone1', 'phone2' or 'fax'")
      @search_phrase = params[:company_number].strip
    end
    if @search_field != nil
      @companies = Company.paginate :order => :name, :per_page => session[:list_limit],
                                    :conditions => ["#{@search_field} LIKE ?",
                                                    "%#{@search_phrase}%"],
                                    :page => params[:page]
    else
      @companies = Company.paginate :order => :name, :per_page => session[:list_limit],
                                    :conditions => ["phone1 LIKE ? OR phone2 LIKE ? OR fax LIKE ?",
                                                    "%#{@search_phrase}%", "%#{@search_phrase}%",
                                                    "%#{@search_phrase}%"],
                                    :page => params[:page]
    end
    # If there was only one search result, just show the company.
    if @companies.length == 1
      flash[:notice] = "<strong>#{@search_phrase}</strong> matched only one company - viewing company now."
      redirect_to :action => :show, :id => @companies[0].id
    end
  end

  def new
    @company = Company.new
  end

  def new_account
    redirect_to :controller => 'accounts', :action => 'new', :id => params[:id]
  end

  def new_contact
    @contact = Contact.new
    @contact.company_ids = params[:id]
    # Assign this new contact the relevant company, using the id we were sent
    @company = Company.find params[:id]
  end

  def create
    @company = Company.new(params[:company])
    @company.created_by = session[:user]
    if @company.save
      flash[:notice] = 'Company was successfully created.'
      redirect_to :action => 'show', :id => @company
    else
      render :action => 'new'
    end
  end

  def edit
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])
    @company.updated_by = session[:user]
    if @company.update_attributes(params[:company])
      flash[:notice] = 'Company was successfully updated.'
      redirect_to :action => 'show', :id => @company
    else
      render :action => 'edit'
    end
  end

  def destroy
    Company.find(params[:id]).destroy
    flash[:notice] = "Company deleted"
    redirect_to :action => 'list'
  end

  def bandwidth_quota_breakdown
    @company = Company.find params[:id]
    render :update do |page|
      page.show 'contentright' # The contentright div might be hidden
      page.replace 'bandwidth_breakdown', :partial => 'bandwidth_breakdown'
      page.visual_effect :highlight, 'bandwidth_breakdown'
    end
  end

  def disk_quota_breakdown
    @company = Company.find params[:id]
    render :update do |page|
      page.show 'contentright' # The contentright div might be hidden
      page.replace 'disk_breakdown', :partial => 'disk_breakdown'
      page.visual_effect :highlight, 'disk_breakdown'
    end
  end
end
