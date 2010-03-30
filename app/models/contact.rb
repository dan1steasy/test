# == Schema Information
# Schema version: 20100208131342
#
# Table name: contacts
#
#  id                   :integer(4)    not null, primary key
#  title                :string(255)   default()
#  forename             :string(255)   
#  phone1               :string(255)   
#  phone2               :string(255)   
#  fax                  :string(255)   
#  email                :string(255)   not null
#  position             :string(255)   
#  is_subscribed        :boolean(1)    default(true), not null
#  is_billing_contact   :boolean(1)    not null
#  is_general_contact   :boolean(1)    not null
#  is_technical_contact :boolean(1)    not null
#  created_at           :date          not null
#  surname              :string(255)   
#  created_by           :integer(4)    
#  updated_by           :integer(4)    
#  updated_at           :date          
#  old_id               :integer(4)    
#  is_active            :boolean(1)    default(true)
#  deactivated_on       :date          
#

class Contact < ActiveRecord::Base
  require_dependency 'note'

  has_and_belongs_to_many :companies

  has_many :contact_notes, :dependent => :destroy

  validates_presence_of   :title, :forename, :surname
  #validates_uniqueness_of :email
  validates_format_of     :email,
                          :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_each :phone1, :phone2, :fax do |model, attribute, value|
    if(value !~ /^[0-9 ()\+\-\.]+$/) and (value != '') and (value != nil)
      model.errors.add(attribute, "is invalid")
    end
  end

  def after_create
    if UPDATE_OLD_AUTOEASY
      create_old
    end
  end

  def after_update
    if UPDATE_OLD_AUTOEASY
      update_old
    end
  end

  def before_destroy
    if UPDATE_OLD_AUTOEASY
      destroy_old
    end
  end

  def full_name
    [self.title, self.forename, self.surname].compact.join(' ')
  end

  def colleagues
    contact_ids = Company.find(self.company_ids).map {|comp| comp.contact_ids}
    contact_ids.flatten!
    if contact_ids.blank?
      []
    else
      contact_ids.uniq!
      contact_ids.delete(self.id)
      Contact.find(contact_ids)
    end
  end

  def self.find_general_contacts(honour_subscribed_preference=false)
    if honour_subscribed_preference
      general_contacts = find :all, :conditions => 'is_general_contact = TRUE AND is_subscribed = TRUE'
    else
      general_contacts = find :all, :conditions => 'is_general_contact = TRUE'
    end
    general_contacts
  end

  def self.find_general_contact_addresses(honour_subscribed_preference=false)
    if honour_subscribed_preference
      general_contacts = find :all, :conditions => 'is_general_contact = TRUE AND is_subscribed = TRUE'
    else
      general_contacts = find :all, :conditions => 'is_general_contact = TRUE'
    end
    email_addresses(general_contacts)
  end

  def self.find_technical_contacts(honour_subscribed_preference=false)
    if honour_subscribed_preference
      technical_contacts = find :all, :conditions => 'is_technical_contact = TRUE AND is_subscribed = TRUE'
    else
      technical_contacts = find :all, :conditions => 'is_technical_contact = TRUE'
    end
    technical_contacts
  end

  def self.find_technical_contact_addresses(honour_subscribed_preference=false)
    if honour_subscribed_preference
      technical_contacts = find :all, :conditions => 'is_technical_contact = TRUE AND is_subscribed = TRUE'
    else
      technical_contacts = find :all, :conditions => 'is_technical_contact = TRUE'
    end
    email_addresses(technical_contacts)
  end

  def self.find_billing_contacts(honour_subscribed_preference=false)
    if honour_subscribed_preference
      billing_contacts = find :all, :conditions => 'is_billing_contact = TRUE AND is_subscribed = TRUE'
    else
      billing_contacts = find :all, :conditions => 'is_billing_contact = TRUE'
    end
    billing_contacts
  end

  def self.find_billing_contact_addresses(honour_subscribed_preference=false)
    if honour_subscribed_preference
      billing_contacts = find :all, :conditions => 'is_billing_contact = TRUE AND is_subscribed = TRUE'
    else
      billing_contacts = find :all, :conditions => 'is_billing_contact = TRUE'
    end
    email_addresses(billing_contacts)
  end

  protected
  def self.email_addresses(contacts)
    email_address_array = []
    contacts.each {|contact| email_address_array << contact.email}
    email_address_array.uniq
  end

  private
  def create_old
    old_contact = OldContact.create_from_new(self)
    self.update_attribute(:old_id, old_contact.id)
  end

  def update_old
    unless self.old_id.blank?
      old_contact = OldContact.find(self.old_id)
      old_contact.update_from_new(self)
    end
  end

  def destroy_old
    unless self.old_id.blank?
      OldContact.find(self.old_id).destroy
    end
  end

end

class OldAE < ActiveRecord::Base
  OldAE.establish_connection :adapter => 'mysql',
                             :host => 'ecrm.1steasy.net',
                             :database => 'AutoEasyV2',
                             :username => 'ecrm',
                             :password => '#eCrM1st22*'
end

class OldContact < OldAE
  set_table_name 'Contacts'
  set_primary_key 'Contact_Id'

  def self.create_from_new(contact)
    contact.is_subscribed ? subscribed = 'yes' : subscribed = 'no'

    OldContact.create!(:Company_Id => contact.companies[0].old_id,
                       :Title => contact.title, :Forename => contact.forename,
                       :Surname => contact.surname, :Phone1 => contact.phone1,
                       :Phone2 => contact.phone2, :Fax => contact.fax,
                       :Email => contact.email, :Position => contact.position,
                       :Subscribed => subscribed)
  end

  def update_from_new(contact)
    contact.is_subscribed ? subscribed = 'yes' : subscribed = 'no'

    self.update_attributes(:Company_Id => contact.companies[0].old_id,
                           :Title => contact.title, :Forename => contact.forename,
                           :Surname => contact.surname, :Phone1 => contact.phone1,
                           :Phone2 => contact.phone2, :Fax => contact.fax,
                           :Email => contact.email, :Position => contact.position,
                           :Subscribed => subscribed)
  end

  def copy_to_new
    self.Subscribed == 'yes' ? is_subscribed = true : is_subscribed = false

    old_company = OldCompany.find self.Company_Id
    new_company = Company.find_by_old_id self.Company_Id

    contact = Contact.create!(:title => self.Title, :forename => self.Forename,
                              :surname => self.Surname, :phone1 => self.Phone1,
                              :phone2 => self.Phone2, :fax => self.Fax,
                              :email => self.Email, :position => self.Position,
                              :is_subscribed => is_subscribed, :created_by => 1,
                              :is_general_contact => true, :is_technical_contact => true,
                              :is_billing_contact => true, :old_id => self.id)
    contact.companies << new_company
    contact.save
  end

end

class VTiger < ActiveRecord::Base
  VTiger.establish_connection configurations['vtiger']
end

class VTContact < VTiger
  set_table_name  'vtiger_account'
  set_primary_key 'accountid'
end
