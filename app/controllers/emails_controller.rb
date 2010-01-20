class EmailsController < ApplicationController

  Email = Struct.new(:use_general, :use_technical, :use_billing, :use_other, :other_addresses,
                     :template_id, :subject, :html_body, :text_body, :subscribers_only)

  def index
    @total_general_contacts   = Contact.count :conditions => 'is_general_contact = TRUE'
    @total_technical_contacts = Contact.count :conditions => 'is_technical_contact = TRUE'
    @total_billing_contacts   = Contact.count :conditions => 'is_billing_contact = TRUE'
    @email_templates          = EmailTemplate.find :all, :order => 'template_name'
    @email                    = Email.new(0, 0, 0, 0, '', @email_templates[0].id, 
                                          @email_templates[0].subject,
                                          @email_templates[0].html_body,
                                          @email_templates[0].text_body, true)
  end

  def for_account
    @account = Account.find params[:id]
    @email = initialize_email_and_template true
  end

  def for_contact
    @contact = Contact.find params[:id]
  end

  def for_company
    @company = Company.find params[:id]
  end

  def for_datacentre
    @datacentre = Datacentre.find params[:id]
    @email = initialize_email_and_template
  end

  def for_cabinet
    @cabinet = Cabinet.find params[:id]
    @hw_contacts, @hosted_contacts = @cabinet.contacts
    @hw_email = initialize_email_and_template
    @hosted_email = initialize_email_and_template
  end

  def load_template
    @email_template = EmailTemplate.find params[:template_id]
    @email = Email.new(0, 0, 0, 0, '', @email_template.id,
                       @email_template.subject, @email_template.html_body,
                       @email_template.text_body, true)
    render :update do |page|
      page << '<script type="text/javascript">'
      page.replace 'email_fields', :partial => 'email_fields', :locals => {:email => @email}
      page.visual_effect :highlight, 'email_fields'
      page << '</script>'
    end
  end

  def load_template_for_account
    @account = Account.find params[:account_id]
    @email_template = EmailTemplate.find params[:template_id]
    @email = Email.new(0, 0, 0, 0, '', @email_template.id,
                       translate_for_account(@email_template.subject),
                       translate_for_account(@email_template.html_body),
                       translate_for_account(@email_template.text_body))
    render :update do |page|
      page << '<script type="text/javascript">'
      page.replace 'email_fields', :partial => 'email_fields', :locals => {:email => @email}
      page.visual_effect :highlight, 'email_fields'
      page << '</script>'
    end
  end

  def send_out
    @email = Email.new(params[:email][:use_general].to_i, params[:email][:use_technical].to_i,
                       params[:email][:use_billing].to_i, params[:email][:use_other].to_i,
                       params[:email][:other_addresses], nil, params[:email][:subject],
                       params[:email][:html_body], params[:email][:text_body],
                       params[:email][:subscribers_only])
    # Build up an array of addresses
    recipients = []
    recipients += Contact.find_general_contact_addresses(@email.subscribers_only) if @email.use_general == 1
    recipients += Contact.find_technical_contact_addresses(@email.subscribers_only) if @email.use_technical == 1
    recipients += Contact.find_billing_contact_addresses(@email.subscribers_only) if @email.use_billing == 1
    if @email.use_other == 1 && @email.other_addresses != ''
      recipients += @email.other_addresses.split(/;|,| |\n/)
    end
    # Now make sure we have only unique values in the recipients array
    recipients.uniq!
    logger.debug("DEBUG >> recipients: '#{recipients}' (#{recipients.size})")
    if recipients.size < 1
      flash[:error] = "You have not specified any recipients!"
      @total_general_contacts   = Contact.count :conditions => 'is_general_contact = TRUE'
      @total_technical_contacts = Contact.count :conditions => 'is_technical_contact = TRUE'
      @total_billing_contacts   = Contact.count :conditions => 'is_billing_contact = TRUE'
      # Load up our email templates
      @email_templates = EmailTemplate.find :all, :order => 'template_name'
      render :action => 'index'
    else
      # Send the email to each recipient
      recipients.each do |recipient|
        AeMailer.deliver_account(@email, recipient)
      end
      if recipients.size > 25
        flash[:notice] = "Email sent to #{recipients.size} recipients"
      else
        flash[:notice] = "Email sent to #{recipients.join(', ')}"
      end
      redirect_to :back
    end
  end

  def send_for_account
    @account = Account.find params[:id]
    @email = Email.new(params[:email][:use_general].to_i, params[:email][:use_technical].to_i,
                       params[:email][:use_billing].to_i, params[:email][:use_other].to_i,
                       params[:email][:other_addresses], nil, params[:email][:subject],
                       params[:email][:html_body], params[:email][:text_body])
    # Build up an array of addresses
    recipients = []
    recipients += @account.general_contact_addresses if @email.use_general == 1
    recipients += @account.technical_contact_addresses if @email.use_technical == 1
    recipients += @account.billing_contact_addresses if @email.use_billing == 1
    if @email.use_other == 1 && @email.other_addresses != ''
      recipients += @email.other_addresses.split(/;|,| /)
    end
    # Now make sure we have only unique values in the recipients array
    recipients.uniq!
    logger.debug("DEBUG >> recipients: '#{recipients}' (#{recipients.size})")
    if recipients.size < 1
      flash[:error] = "You have not specified any recipients!"
      # Load up our email templates
      @email_templates = EmailTemplate.find :all, :order => 'template_name'
      render :action => 'for_account'
    else
      # Send the email
      AeMailer.deliver_account(@email, recipients)
      flash[:notice] = "Email sent to #{recipients.join(', ')}"
      redirect_to account_url(:fqdn => @account.fqdn)
    end
  end

  def send_for_cabinet
    @cabinet = Cabinet.find params[:id]
    # We seem to need to convert our boolena strings manually...
    if params[:hw_email][:subscribers_only] == 'true'
      params[:hw_email][:subscribers_only] = true
    else
      params[:hw_email][:subscribers_only] = false
    end
    @hw_email = Email.new(params[:hw_email][:use_general].to_i, params[:hw_email][:use_technical].to_i,
                          params[:hw_email][:use_billing].to_i, params[:hw_email][:use_other].to_i,
                          params[:hw_email][:other_addresses], nil, params[:email][:subject],
                          params[:email][:html_body], params[:email][:text_body], params[:hw_email][:subscribers_only])
    # We only need to set up @hosted_email for the recipients...
    unless params[:hosted_email].blank?
      @hosted_email = Email.new(params[:hosted_email][:use_general].to_i, params[:hosted_email][:use_technical].to_i,
                                params[:hosted_email][:use_billing].to_i, 0,
                                0, nil, params[:email][:subject],
                                params[:email][:html_body], params[:email][:text_body], params[:hw_email][:subscribers_only])
    end
    # Load up all the subscribed addresses for this cabinet
    hw, hosted = @cabinet.contacts(true, @hw_email.subscribers_only)
    # Build up an array of recipient_addresses
    recipients = []
    # Add all our relevant hardware owner addresses
    recipients += hw[:billing] if @hw_email.use_billing == 1
    recipients += hw[:general] if @hw_email.use_general == 1
    recipients += hw[:technical] if @hw_email.use_technical == 1
    if @hw_email.use_other == 1 && @hw_email.other_addresses != ''
      recipients += @hw_email.other_addresses.split(/;|,|\n| /)
    end
    unless params[:hosted_email].blank?
      # Add all our relevant hosted customers
      ['billing', 'general', 'technical'].each do |contact_type|
        if @hosted_email.send("use_#{contact_type}") == 1
          hosted[contact_type.to_sym].each do |server|
            recipients += server[1]
          end
        end
      end
    end
    recipients.uniq!
    logger.debug("DEBUG >> recipients: '#{recipients}' (#{recipients.size})")
    if recipients.size < 1
      flash[:error] = "You have not specified any recipients!"
      # Load up our email templates
      @email_templates = EmailTemplate.find :all, :order => 'template_name'
      # Load up our contacts
      @hw_contacts, @hosted_contacts = @cabinet.contacts
      render :action => 'for_cabinet'
    else
      # Send the email, one recipient at a time
      recipients.each do |recipient|
        AeMailer.deliver_account(@hw_email, recipient)
      end
      if recipients.size > 25
        flash[:notice] = "Email sent to #{recipients.size} recipients"
      else
        flash[:notice] = "Email sent to #{recipients.join(', ')}"
      end
      redirect_to :controller => :dc, :action => :show, :id => @cabinet.datacentre
    end

  end

  private
  def initialize_email_and_template(for_account=false)
    @email_templates = EmailTemplate.find :all, :order => 'template_name'
    if for_account
      email = Email.new(0, 0, 0, 0, '', @email_templates[0].id,
                        translate_for_account(@email_templates[0].subject),
                        translate_for_account(@email_templates[0].html_body),
                        translate_for_account(@email_templates[0].text_body), true)
    else
      email = Email.new(0, 0, 0, 0, '', @email_templates[0].id, @email_templates[0].subject,
                        @email_templates[0].html_body, @email_templates[0].text_body, true)
    end
    email
  end

  def translate_for_account(string_to_translate)
    # Method to translate any variables from an email
    # template to the correct values for this account.
    if string_to_translate.blank?
      return ''
    else
      string_to_translate.gsub!('[[FQDN]]', @account.fqdn)
      string_to_translate.gsub!('[[DOMAIN]]', @account.domain_name)
      string_to_translate.gsub!('[[HOSTING_SERVER]]', @account.hardware.name)
      string_to_translate.gsub!('[[SECURE_URL]]', "https://#{@account.hardware.name}/#{@account.secure_link}")
      string_to_translate.gsub!('[[SITE_ADMIN_USER]]', @account.find_username('site_admin', session[:user]))
      string_to_translate.gsub!('[[SITE_ADMIN_PASS]]', @account.find_password('site_admin', session[:user]))
      string_to_translate.gsub!('[[MIVA_ADMIN_USER]]', @account.find_username('miva_admin', session[:user]))
      string_to_translate.gsub!('[[MIVA_ADMIN_PASS]]', @account.find_password('miva_admin', session[:user]))
      string_to_translate.gsub!('[[SERVER_ADMIN_USER]]', @account.find_username('server_admin', session[:user]))
      string_to_translate.gsub!('[[SERVER_ADMIN_PASS]]', @account.find_password('server_admin', session[:user]))
      string_to_translate.gsub!('[[ROOT_USER]]', @account.find_username('root_user', session[:user]))
      string_to_translate.gsub!('[[ROOT_PASS]]', @account.find_password('root_user', session[:user]))
      return string_to_translate
    end
  end

end
