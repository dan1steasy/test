# == Schema Information
# Schema version: 20100120120153
#
# Table name: accounts
#
#  id               :integer(4)    not null, primary key
#  company_id       :integer(4)    
#  host_name        :string(255)   
#  domain_name      :string(255)   
#  hardware_id      :integer(4)    
#  secure_link      :string(255)   
#  created_at       :datetime      
#  support_level_id :integer(4)    
#  updated_at       :datetime      
#  account_type_id  :integer(4)    
#  created_by       :integer(4)    
#  updated_by       :integer(4)    
#  is_active        :boolean(1)    default(true)
#  deactivated_on   :date          
#

class Account < ActiveRecord::Base
  gem 'pNet-DNS'
  require 'Net/DNS'
  require_dependency 'login_detail'
  require_dependency 'note'

  include Whois

  belongs_to :company
  belongs_to :hardware # e.g. dedicated or shared server
  belongs_to :support_level
  belongs_to :account_type

  # Accounts also need to be associated with Products,
  has_and_belongs_to_many :products
  # Accounts also need to be associated with OrderItems
  has_many :order_items
  has_many :account_logins,  :dependent => :destroy
  has_many :account_notes,   :dependent => :destroy
  has_many :licences,        :dependent => :nullify
  has_one  :disk_quota,      :dependent => :destroy
  has_one  :bandwidth_quota, :dependent => :destroy
  has_one  :ssl,             :dependent => :nullify

  validates_presence_of :domain_name
  validates_numericality_of :account_type_id, :message => "must be selected"
  validates_uniqueness_of :host_name,   :scope => :domain_name
  validates_uniqueness_of :domain_name, :scope => :host_name
  validates_uniqueness_of :secure_link, :scope => :hardware_id,
                          :allow_nil => true
  validates_format_of :domain_name,
                      :with => /^([\w-]+\.){1,4}[\w]+$/,
                      :message => "is not a valid domain name"
  validates_format_of :host_name, :with => /[^\.]$/,
                      :message => "is not a valid host name"

  def before_validation
    self.secure_link = nil if self.secure_link == ''
  end

  def before_create
    self.host_name.downcase!
    self.domain_name.downcase!
  end

  def before_destroy
    if is_hardware?
      raise "This account is hardware - cannot delete!"
    end
  end

  attr_accessor :product_id # we need this to be able to pass in a product when adding an account

  # Method to return fully qualified domain name
  def fqdn
    if(self.host_name != nil) and (self.host_name != '')
      [self.host_name, self.domain_name].compact.join('.')
    else
      self.domain_name
    end
  end

  def fqdn_with_status
    fqdn = self.fqdn
    if self.is_active
      fqdn
    else
      fqdn + ' (deactivated)'
    end
  end

  # Method to find an account by its fqdn
  def self.find_by_fqdn(fqdn)
    sql = "CONCAT(host_name, '.', domain_name) LIKE ? OR domain_name LIKE ?"
    account = Account.find(:first, :conditions => [sql, fqdn, fqdn])
    if account.blank?
      raise "No domain found for #{fqdn}"
    end
    account
  end

  # Method to return all deactivated accounts
  def self.find_deactivated
    find :all, :conditions => ["is_active = ?", false], :order => "domain_name, host_name"
  end

  # Method to utilise Whois library nameservers function
  def nameservers
    listed_nameservers self.domain_name
  end

  # Method to return the IP address(es)
  def ip_addresses(resolve=false)
    ip_addresses = {:hosting_server_ip_addresses => []}
    self.hardware.ip_addresses.each do |ip|
      ip_addresses[:hosting_server_ip_addresses] << ip.address
    end
    if resolve
      begin
        resolver = Net::DNS::Resolver.new
        resolver.tcp_timeout = 2
        resolver.udp_timeout = 2
        rq_result = resolver.query(self.fqdn)
        ip_addresses[:resolved_ip_address] = rq_result.answer[0].address
      rescue
        ip_addresses[:resolved_ip_address] = nil
      end
    end
    ip_addresses
  end


  # Method to return formatted disk quota
  def disk_quota_value
    if self.disk_quota.blank?
      "0" + DiskQuota::UNIT + " (No disk quota set)"
    else
      self.disk_quota.value.to_s + DiskQuota::UNIT
    end
  end

  # Method to return formatted bandwidth quota
  def bandwidth_quota_value
    if self.bandwidth_quota.blank?
      "0" + BandwidthQuota::UNIT + " (No bandwidth quota set)"
    else
      self.bandwidth_quota.value.to_s + BandwidthQuota::UNIT
    end
  end

  def is_hardware?
    if Hardware.count(:conditions => ['name = ?', self.fqdn]) > 0
      true
    else
      false
    end
  end

  def has_ssl?
    if self.ssl.blank?
      false
    else
      true
    end
  end

  # Method to return an array of the general contact email addresses
  def general_contact_addresses
    addresses = []
    self.company.contacts.map {|contact| addresses << contact.email if contact.is_general_contact}
    addresses
  end

  # Method to return an array of the technical contact email addresses
  def technical_contact_addresses
    addresses = []
    self.company.contacts.map {|contact| addresses << contact.email if contact.is_technical_contact}
    addresses
  end

  # Method to return an array of the billing contact email addresses
  def billing_contact_addresses
    addresses = []
    self.company.contacts.map {|contact| addresses << contact.email if contact.is_billing_contact}
    addresses
  end

  def find_username(type, user_id)
    case type
    when 'site_admin'
      description = 'Site admin'
    when 'server_admin'
      description = 'Server admin'
    when 'miva_admin'
      description = 'Miva admin'
    when 'root_user'
      description = 'Root user'
    end
    # We must assume there will be only one site/server/miva admin, so limit to first result
    login = AccountLogin.find(:first, :conditions =>
                                      "account_id = #{self.id} AND description LIKE '#{description}'")
    if login.blank?
      # If we couldn't find a login of this type, just return the email
      # template variable name, to make it easy to spot failures in the
      # template.
      case type
      when 'site_admin'
        '[[SITE_ADMIN_USER]]'
      when 'server_admin'
        '[[SERVER_ADMIN_USER]]'
      when 'miva_admin'
        '[[MIVA_ADMIN_USER]]'
      when 'root_user'
        '[[ROOT_USER]]'
      end
    else
      # Return the decrypted username that matches our type
      login.decrypt_username(decryption_key(user_id))
    end
  end

  def find_password(type, user_id)
    case type
    when 'site_admin'
      description = 'Site admin'
    when 'server_admin'
      description = 'Server admin'
    when 'miva_admin'
      description = 'Miva admin'
    when 'root_user'
      description = 'Root user'
    end
    # We must assume there will be only one site/server/miva admin, so limit to first result
    login = AccountLogin.find(:first, :conditions =>
                                      "account_id = #{self.id} AND description LIKE '#{description}'")
    if login.blank?
      # If we couldn't find a login of this type, just return the email
      # template variable name, to make it easy to spot failures in the
      # template.
      case type
      when 'site_admin'
        '[[SITE_ADMIN_PASS]]'
      when 'server_admin'
        '[[SERVER_ADMIN_PASS]]'
      when 'miva_admin'
        '[[MIVA_ADMIN_PASS]]'
      when 'root_user'
        '[[ROOT_PASS]]'
      end
    else
      # Return the decrypted password that matches our type
      login.decrypt_password(decryption_key(user_id))
    end
  end

  private
  def decryption_key(user_id)
    user = User.find user_id
    user.decrypt_key
  end
end
