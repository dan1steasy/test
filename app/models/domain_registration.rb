# == Schema Information
# Schema version: 82
#
# Table name: domain_registrations
#
#  id                :integer(11)   not null, primary key
#  company_id        :integer(11)   
#  tld               :string(255)   
#  domain_name       :string(255)   
#  registrar_id      :integer(11)   
#  renewal_date      :date          
#  reg_period        :integer(11)   
#  registration_date :date          
#  last_updated      :date          
#

class DomainRegistration < ActiveRecord::Base

  include Whois

  belongs_to :company
  belongs_to :registrar

  validates_presence_of   :tld, :domain_name
  validates_uniqueness_of :domain_name, :scope => :tld

  # If appropriate, we need to update any API when
  # making changes.
  #def before_create
  #  if self.registrar.has_api?
  #    register
  #  end
  #end

  # Method to return fully qualified domain name
  def fqdn
    self.domain_name + '.' + self.tld
  end

  # Method to check if a domains is free.
  def is_available?
    status = check_status(self.fqdn)
    return status.blank?
  end

  # Method to check if a domain is registered under our account.
  def is_registered?
    if self.registrar.has_api?
      require "#{self.registrar.name.downcase}/api_request"
      api = ApiRequest.new(self.registrar.decrypted_username,
                           self.registrar.decrypted_password,
                           self.registrar.url)
      result = api.check_domains(self.domain_name, self.tld)
      case result['RRPCode']
      when "211"
        return false
      when "210"
        return true
      else
        return false
      end
    end
  end

  # Method to make sure we update any API when
  # registering (creating a domain).
  def register
    if self.registrar.has_api?
      require "#{self.registrar.name.downcase}/api_request"
      # The registrar's username and password need to be decrypted
      # before calling this method.
      api = ApiRequest.new(self.registrar.decrypted_username,
                           self.registrar.decrypted_password,
                           self.registrar.url)
      # Register the domain
      api.register(self.domain_name, self.tld)
    end
  end

end
