class EmailTemplatesController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  def list
    @email_templates = EmailTemplate.find :all, :order => 'template_name'
  end

  def show
    @email_template = EmailTemplate.find params[:id]
  end

  def preview
    @email_template = EmailTemplate.find params[:id]
    render :text => @email_template.html_body
  end

  def new
    @email_template = EmailTemplate.new
  end

  def create
    @email_template = EmailTemplate.new params[:email_template]
    if @email_template.save
      flash[:notice] = "Email template saved."
      redirect_to :action => 'show', :id => @email_template
    else
      flash[:error] = "Could not save email template!"
      render :action => 'new'
    end
  end

  def edit
    @email_template = EmailTemplate.find params[:id]
  end

  def update
    @email_template = EmailTemplate.find params[:id]
    if @email_template.update_attributes params[:email_template]
      flash[:notice] = "Email template updated."
      redirect_to :action => 'show', :id => @email_template
    else
      flash[:error] = "Changes could not be saved!"
      render :action => 'edit'
    end
  end

  def destroy
    EmailTemplate.find(params[:id]).destroy
    flash[:notice] = 'Email template deleted.'
    redirect_to :action => 'index'
  end
end
