# == Schema Information
# Schema version: 20100120120153
#
# Table name: ip_addresses
#
#  id          :integer(4)    not null, primary key
#  address     :string(15)    not null
#  company_id  :integer(4)    
#  hardware_id :integer(4)    
#

class IpAddress < ActiveRecord::Base
  require 'resolv'

  belongs_to :company
  belongs_to :hardware

  validates_uniqueness_of :address, :on => :create, :if => :not_local_network
  validates_format_of :address,
    :with => /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/

  # Add some accessors to use in our forms
  attr_accessor :no_company, :no_hardware, :method, :network, :start, :end

  # Struture for use in 'available_ips_for_select' method
  SelectableIp = Struct.new(:id, :address)

  # Class for use in 'available_ips_for_select' method
  class IpType
    attr_reader :type_name, :options
    def initialize(name)
      @type_name = name
      @options = []
    end
    def <<(option)
      @options << option
    end
  end

  def assigned?
    if self.company_id == nil && self.hardware_id == nil
      return false
    else
      return true
    end
  end

  def assigned_to_company?
    if self.company_id != nil
      return true
    else
      return false
    end
  end

  def assigned_to_hardware?
    if self.hardware_id != nil
      return true
    else
      return false
    end
  end

  def ptr
    begin
      Resolv.getname self.address
    rescue Resolv::ResolvError
      "No PTR record"
    rescue Errno::ENETUNREACH
      "Network unreachable"
    end
  end

  def self.find_all_in_address_order
    IpAddress.find :all, :order => 'INET_ATON(address) ASC'
  end

  # Method to return the networks that we have, based on the IP addresses
  # that exist. Optionally takes a company argument to narrow results to
  # networks allocated to one company.
  def self.find_networks(company=nil)
    select = "DISTINCT SUBSTRING_INDEX(address, '.', 3) AS network"
    order  = 'INET_ATON(address) ASC'
    if company == nil
      IpAddress.find :all, :select => select, :order => order 
    else
      IpAddress.find :all, :select => select, :conditions => ['company_id = ?', company.id],
                     :order => order
    end
  end

  def self.unassigned_ips
    IpAddress.find :all, :conditions => ["company_id IS NULL AND hardware_id IS NULL"],
                   :order => 'INET_ATON(address) ASC'
  end

  # Return a list of unassigned IPs and IPs assigned to the provided company
  def self.available_ips(company_id)
    IpAddress.find :all,
      :conditions => ["(company_id IS NULL AND hardware_id IS NULL) OR (company_id = ? AND hardware_id IS NULL)",
                      company_id],
      :order => 'INET_ATON(address) ASC'
  end

  def self.available_ips_for_select(company_id=nil, assigned_ip_ids=nil)
    ip_list = []

    # Make sure that company_id is valid.
    if company_id =~ /^\d$/
      company_id = company_id.to_i
    elsif !company_id.is_a? Integer
      company_id = nil
    end
    # Get the currently hardware-assigned IPs, if applicable.
    unless assigned_ip_ids.blank?
      ip_type = IpType.new('Current IP allocations')
      assigned_ips = IpAddress.find :all, :conditions => "id IN(#{assigned_ip_ids.join(',')})",
                                    :order => 'INET_ATON(address) ASC'
      assigned_ips.each do |ip|
        ip_type << SelectableIp.new(ip.id, ip.address)
      end
      ip_list << ip_type
    end
    # Get the group of IPs for this company
    unless company_id == nil
      ip_type = IpType.new(Company.find(company_id).name + " allocated IPs")
      company_ips = IpAddress.find :all, :conditions => ["hardware_id IS NULL AND company_id = ?",
                                                         company_id],
                                   :order => 'INET_ATON(address) ASC'
      company_ips.each do |ip|
        ip_type << SelectableIp.new(ip.id, ip.address)
      end
      ip_list << ip_type
    end
    ip_type = IpType.new("Unallocated free IPs")
    unassigned_ips = self.unassigned_ips
    unassigned_ips.each do |ip|
      ip_type << SelectableIp.new(ip.id, ip.address)
    end
    ip_list << ip_type
    ip_list
  end

  private
  def not_local_network
    if self.address =~ /(^192\.168\.|^10\.)/
      return false
    else
      return true
    end
  end
end
