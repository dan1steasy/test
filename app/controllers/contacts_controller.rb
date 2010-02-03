class ContactsController < ApplicationController

  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  #model :note
  require 'dcp_account'

  auto_complete_for :contact, :email

  Contact.content_columns.each do |column|
    in_place_edit_with_update_for :contact, column.name unless column.name == 'email'
  end

  # Manually write set_contact_email to use validations
  def set_contact_email
    @contact = Contact.find(params[:id])
    old_email = @contact.email
    @contact.email = params[:value]
    if @contact.save
      @contact.update_attribute('updated_by', session[:user])
      render :update do |page|
        page.replace("contact_email_#{params[:id]}_in_place_editor",
                      in_place_editor_field(:contact, :email, {}, {:rows => 1}))
      end
    else
      # Grab the error message to display on a JS alert
      err_msg = @contact.errors[:email]
      @contact.email = old_email
      @contact.save
      render :update do |page|
        page.replace("contact_email_#{params[:id]}_in_place_editor",
                      in_place_editor_field(:contact, :email, {:value => old_email}, {:rows => 1}))
        page.call("alert", "Supplied email " + err_msg + "\nReverted to original value.")
      end
    end
  end

  def index
    @total_contacts = Contact.count
    @contacts = Contact.find :all, :order => 'surname, forename' unless @total_contacts > 500
    # Set up a new emtpy contact for use on the quick-add form
    @contact = Contact.new(:is_subscribed => 'true')
    # We need all our companies for the quick-add form too.
    @companies = Company.find :all, :order => 'name'
  end

  def list
    # Assemble an order string to use in these queries
    order = 'surname, forename'
    if params[:id]
      @search_phrase = params[:id]
      # Assemble conditions that will be used when loading contacts and contact_pages
      conditions = ["forename LIKE ? OR surname LIKE ?", "#{@search_phrase}%", "#{@search_phrase}%"]
      @total_contacts = Contact.count :conditions => conditions
      @contacts = Contact.paginate :order => order, :conditions => conditions,
                                   :per_page => session[:list_limit], :page => params[:page]
    else
      @total_contacts = Contact.count
      @contacts = Contact.paginate :order => order, :per_page => session[:list_limit],
                                   :page => params[:page]
    end
  end

  def show
    if request.post?
      redirect_to :action => 'show', :id => params[:contact][:id] and return
    else
      @contact = Contact.find params[:id]
      @colleagues = @contact.colleagues
      contacts_company_ids = @contact.companies.map {|comp| comp.account_ids}
      @accounts = Account.find(contacts_company_ids) unless contacts_company_ids.flatten.empty?
      # Get the relevant notes
      if User.find(session[:user]).is_in_finance
        @contact_notes = @contact.contact_notes
      else
        @contact_notes = @contact.contact_notes.find(:all, :conditions => ['is_financial = ?', false])
      end
    end
  end

  def auto_complete_for_contact_full_name
    @search_phrase = params[:contact_full_name].strip
    @contacts = Contact.find :all, :order => :surname,
                             :conditions => ["CONCAT(title, ' ', forename, ' ', surname) LIKE ?",
                                             "%#{@search_phrase}%"]
    render :layout => false
  end

  def auto_complete_for_contact_number
    @search_phrase = params[:contact_number].strip
    cond_array = ["phone1 LIKE ? OR phone2 LIKE ? OR fax LIKE ?"]
    3.times { cond_array << "%#{@search_phrase}%" }
    @contacts = Contact.find :all, :order => :surname,
                             :conditions => cond_array
    render :layout => false
  end

  def search
    if params[:contact_full_name]
      logger.debug("DEBUG >> Searching on contact 'full_name'")
      @search_phrase = params[:contact_full_name].strip
      # Break the search term into separate words and create a search on each provided word
      search_words = @search_phrase.split
      cond_array = ["CONCAT(title, ' ', forename, ' ', surname) LIKE ?", "%#{@search_phrase}%"]
    elsif params[:contact_number]
      logger.debug("DEBUG >> Searching on contact 'phone1', 'phone2' or 'fax'")
      @search_phrase = params[:contact_number].strip
      cond_array = ["phone1 LIKE ? OR phone2 LIKE ? OR fax LIKE ?"]
      3.times { cond_array << "%#{@search_phrase}%" }
    elsif params[:contact] != nil
      if params[:contact][:email]
        logger.debug("DEBUG >> Searching on contact 'email'")
        @search_phrase = params[:contact][:email].strip
        cond_array = ["email LIKE ?", "%#{@search_phrase}%"]
      end
    end
    @contact_pages = Contact.paginate :order => 'surname, forename', :page => params[:page],
                                      :per_page => session[:list_limit], :conditions => cond_array
    @contacts = Contact.find :all, :conditions => cond_array, :order => 'surname, forename'
    # If there was only one search result, just show the contact.
    if @contacts.length == 1
      flash[:notice] = "<strong>#{@search_phrase}</strong> matched only one contact - viewing contact now."
      redirect_to :action => :show, :id => @contacts[0].id
    end
  end

  def new
    # We need all the available companies to put in a drop-down
    @companies = Company.find :all, :order => :name
    @contact = Contact.new
  end

  def create
    # We need all the available companies to put in a drop-down
    @companies = Company.find :all, :order => :name
    @contact = Contact.new params[:contact]
    @contact.created_by = session[:user]
    @contact.company_ids = params[:company_ids]
    if @contact.save
      flash[:notice] = 'Contact was successfully created.'
      redirect_to :action => 'show', :id => @contact
    else
      render :action => 'new'
    end
  end

  def edit
    @companies = Company.find :all, :order => :name
    @contact = Contact.find params[:id]
  end

  def update
    @contact = Contact.find params[:id]
    # Update the updated_by column
    @contact.updated_by = session[:user]
    @contact.company_ids = params[:company_ids]
    if @contact.update_attributes params[:contact]
      flash[:notice] = 'Contact was successfully updated.'
      redirect_to :action => 'show', :id => @contact
    else
      render :action => 'edit'
    end
  end

  def choose_dcp_company
    @contact = Contact.find params[:id]
    render :layout => false
  end

  def create_dcp_account
    @contact = Contact.find params[:id]
    # We might have been sent a company_id...
    unless params[:company_id].blank?
      @company = Company.find params[:company_id]
    else
      # Just use the first (only) company associated with contact.
      @company = @contact.companies[0]
    end
    # Create the DCP user and keep hold of our cleartext password
    @dcp_user, dcp_user_password = 
      DcpUser.create_from_contact(@contact, @company)
    # Create the DCP profile for this DCP user from the company info
    @dcp_profile = DcpProfile.create_from_company(@dcp_user, @company)
    # Create the a DCP contact for this DCP user from the contact info
    @dcp_contact = DcpContact.create_from_contact(@dcp_user, @contact)
    # Store these details as a contact note
    note_string = "DCP Account:<br />Username: #{@dcp_user.User_Name}" +
                  "<br />Password: #{dcp_user_password}<br />" +
                  "Memorable word: #{@dcp_user.Memory}"
    contact_note = ContactNote.new(User.find(session[:user]).decrypt_key,
                                   :contact_id => @contact.id,
                                   :created_by => session[:user],
                                   :decrypted_note => note_string)
    contact_note.save!
    contact_note.encrypt_note
    # Store these details as a company note
    company_note = CompanyNote.new(User.find(session[:user]).decrypt_key,
                                   :company_id => @company.id,
                                   :created_by => session[:user],
                                   :decrypted_note => note_string)
    company_note.save!
    company_note.encrypt_note
    # Email these details to customer
    AeMailer.deliver_dcp_account(@contact, @dcp_user, dcp_user_password)
    flash[:notice] = "DCP Account created.<br />Email sent to #{@contact.email}."
    redirect_to :action => 'show', :id => @contact
  end

  def destroy
    Contact.find(params[:id]).destroy
    flash[:notice] = "Contact deleted"
    redirect_to :action => 'index'
  end
end
