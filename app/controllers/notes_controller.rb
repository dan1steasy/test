class NotesController < ApplicationController

  require 'note'

  def list_company_notes
    @company_notes = CompanyNote.find_by_company_id(params[:id])
  end

  def show
    @note = Note.find(params[:id])
    # We need to set up a div id for our partial
    @div_id = "note_div_" + @note.id.to_s
    render :partial => 'show'
  end

  def show_company_note
    @company_note = CompanyNote.find(params[:id])
  end

  def show_conotact_note
    @comtact_note = ContactNote.find(params[:id])
  end

  def show_account_note
    @account_note = AccountNote.find(params[:id])
  end

  def new_company_note
    @company_note = CompanyNote.new(User.find(session[:user]).decrypt_key)
    @company_note.company_id = params[:id]
    @company_note.created_by = session[:user]
    render :layout => false
  end

  def new_contact_note
    @contact_note = ContactNote.new(User.find(session[:user]).decrypt_key)
    @contact_note.contact_id = params[:id]
    @contact_note.created_by = session[:user]
    render :layout => false
  end

  def new_account_note
    @account_note = AccountNote.new(User.find(session[:user]).decrypt_key, params[:account_note])
    @account_note.account_id = params[:id]
    @account_note.created_by = session[:user]
    render :layout => false
  end

  def create_company_note
    @company_note = CompanyNote.new(User.find(session[:user]).decrypt_key, params[:company_note])
    if @company_note.save
      @company_note.encrypt_note
      flash[:notice] = 'Company note saved and encrypted.'
    else
      flash[:error] = 'Unable to add note!'
    end
    redirect_to :controller => 'companies', :action => 'show', :id => @company_note.company_id
  end

  def create_contact_note
    @contact_note = ContactNote.new(User.find(session[:user]).decrypt_key, params[:contact_note])
    if @contact_note.save
      @contact_note.encrypt_note
      flash[:notice] = 'Contact note saved and encrypted.'
    else
      flash[:error] = 'Unable to add note!'
    end
    redirect_to :controller => 'contacts', :action => 'show', :id => @contact_note.contact_id
  end

  def create_account_note
    @account_note = AccountNote.new(User.find(session[:user]).decrypt_key, params[:account_note])
    if @account_note.save
      @account_note.encrypt_note
      flash[:notice] = 'Account note saved and encrypted.'
    else
      flash[:error] = 'Unable to add note!'
    end
    redirect_to :controller => 'accounts', :action => 'show', :id => @account_note.account_id
  end

  def edit
    @note = Note.find(params[:id])
    @note.decrypted_note = @note.decrypt_note(User.find(session[:user]).decrypt_key)
    # We need to set up a div id for our rhtml
    @div_id = "note_div_" + @note.id.to_s
    render :layout => false
  end

  def update
    @note = Note.find(params[:id])
    # Update the is_financial flag if we've been sent it
    @note.update_attribute(:is_financial, params[:note][:is_financial]) unless params[:note][:is_financial].blank?
    @note.decrypted_note = params[:note][:decrypted_note]
    # Update the note text
    @note.encrypt_note(User.find(session[:user]).decrypt_key)
    @note.reload
    # Update the updated_by column
    @note.update_attribute :updated_by, session[:user]
    flash[:notice] = "Note updated."
    redirect_on_type
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    flash[:notice] = "Note deleted."
    redirect_on_type
  end

  private
  def redirect_on_type
    case @note[:type]
    when 'CompanyNote'
      controller = 'companies'
      id = @note.company_id
    when 'ContactNote'
      controller = 'contacts'
      id = @note.contact_id
    when 'AccountNote'
      controller = 'accounts'
      id = @note.account_id
    end
    redirect_to :controller => controller, :action => 'show', :id => id
  end

end
