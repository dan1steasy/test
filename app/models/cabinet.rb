# == Schema Information
# Schema version: 20090925131705
#
# Table name: cabinets
#
#  id            :integer(4)    not null, primary key
#  name          :string(255)   
#  description   :text          
#  datacentre_id :integer(4)    
#  u_space       :integer(4)    
#

class Cabinet < ActiveRecord::Base
  belongs_to :datacentre
  has_many :hardware

  validates_presence_of     :name, :u_space, :datacentre_id
  validates_uniqueness_of   :name, :scope => :datacentre_id
  validates_numericality_of :u_space

  # Structure for use in 'cabinet_list_by_datacentre' method.
  CabinetDatacentre = Struct.new(:id, :name)

  # Class for use in 'cabinet_list_by_datacentre' method.
  class CabinetType
    attr_reader :type_name, :options
    def initialize(name)
      @type_name = name
      @options = []
    end
    def <<(option)
      @options << option
    end
  end

  # Create a grouped selection list
  def self.cabinet_list_by_datacentre
    cab_list = []
    datacentres = Datacentre.find :all, :order => 'name'
    datacentres.each do |dc|
      cab_type = CabinetType.new(dc.name)
      cabinets = dc.cabinets.find :all, :select => 'id, name', :order => 'name'
      cabinets.each do |cab|
        cab_type << CabinetDatacentre.new(cab.id, cab.name)
      end
      cab_list << cab_type
    end
    cab_list
  end

  # Generate a list of available cabinet bays for use in a selection list.
  def available_bay_list(u_size_required, hardware_id=nil)
    # If u_size_required is blank, just return a message.
    if u_size_required.blank?
      return ['Provide a U size and select a cabinet to see available bays.']
    end
    # First, find all the pieces of hardware in this cabinet (except the one we pass to the method,
    # which is done when calling this method from an 'edit' page.
    if hardware_id.blank?
      conditions = ["cabinet_id = ?", self.id]
    else
      conditions = ["cabinet_id = ? AND id <> ?", self.id, hardware_id.to_i]
    end
    hardware_in_cabinet = Hardware.find :all, :conditions => conditions,
                                        :order => 'starting_cabinet_bay'
    # Loop through the pieces of hardware, creating a list of filled bays
    filled_bays = []
    hardware_in_cabinet.each do |hwc|
      current_bay = hwc.starting_cabinet_bay
      hwc.u_size.times do
        filled_bays << current_bay
        current_bay += 1
      end
    end
    
    # Now we need to create a list of empty bays
    empty_bays = []
    current_bay = 1
    self.u_space.times do
      empty_bays << current_bay unless filled_bays.include?(current_bay)
      current_bay += 1
    end

    # Now we need to check that our u_size_required will fit into the available spaces
    # First, create an array of arrays that describes the required bays for our u_size_required
    req_bay_ctr = self.u_space - (u_size_required -1) # This is the number of arrays we need inside
                                                      # our required_bays array.
    required_bays = []
    bay_ctr = 1

    req_bay_ctr.times do
      req_bay_array = []
      new_bay_ctr = bay_ctr
      u_size_required.times do
        req_bay_array << new_bay_ctr
        new_bay_ctr += 1
      end
      required_bays << req_bay_array
      bay_ctr += 1
    end

    # Now work through our required_bays array to find out which spaces are available for our u_size
    available_bay_list = []
    required_bays.each do |rb|
      ctr = 0
      while ctr < empty_bays.length
        if empty_bays[ctr, u_size_required] == rb
          if u_size_required == 1
            available_bay_list << [rb[0], rb[0]]
          else
            available_bay_list << ["#{rb[0]} (Bays #{rb[0]} - #{rb[-1]} available)", rb[0]]
          end
        end
        ctr += 1
      end
    end
    # A list to be used in a select, with id's being the starting_bay number for the hardware.
    if available_bay_list.length < 1
      ['No space left in this cabinet']
    else
      available_bay_list 
    end
  end
  alias available_bays_for_select available_bay_list

  # Method to check if a u_size hardware will fit in the cabinet. Returns boolean
  def space_available_for(hardware)
    space_available = true
    # If we're sent nil, just return true.
    return space_available
    # First, simply check it isn't bigger than the cabinet
    if hardware.u_size > self.u_space
      space_available = false
    else
      cabinet_bays = [self.u_space, true]
      # Find all the filled cabinet bays
      hardware_in_cabinet = Hardware.find :all, :conditions => ["cabinet_id = ?", self.id],
                                          :order => 'starting_cabinet_bay'
      # Loop through the pieces of hardware, creating a list of filled bays
      filled_bays = []
      hardware_in_cabinet.each do |hwc|
        current_bay = hwc.starting_cabinet_bay
        hwc.u_size.times do
          filled_bays << current_bay unless hwc.id == hardware.id # Don't add the machine we're
                                                                  # checking for - this breaks
                                                                  # update actions
          current_bay += 1
        end
      end

      # Loop through our filled_bays and modify cabinet_bays.
      filled_bays.each do |filled_bay|
        cabinet_bays[filled_bay] = false
      end

      # Now we need to look through cabinet_bays and check that our required u spaces are 'true'
      ctr = hardware.starting_cabinet_bay
      end_bay = hardware.starting_cabinet_bay + hardware.u_size - 1
      while ctr <= end_bay
        if cabinet_bays[ctr] == false
          space_available = false
          break
        end
        ctr += 1
      end
    end
    space_available
  end

  def is_empty?
    if self.hardware.size < 1
      true
    else
      false
    end
  end

  def contacts(email_only=false, subscribers_only=false)
    hw_comps = [] # an array of hardware-owning companies
    hosted_comps = {} # an array of companies with accounts on the hardware
    self.hardware.each do |hw|
      hw_comps << hw.company_id
      if hw.accounts.size > 1
        hosted_comps[hw.name] = []
        hw.accounts.each do |acc|
          hosted_comps[hw.name] << acc.company_id
        end
        hosted_comps[hw.name].uniq!
      end
    end
    hw_comps.uniq!
    # hw_comps now contains an array of hardware owner company ids
    # hosted_comps now contains a hash of arrays of hosted account company ids
    # we now need to remove any duplicates in the hosted hash
    hosted_comps.each do |server_comps|
      hw_comps.each do |comp_id|
        server_comps[1].delete comp_id
      end
    end
    # Now we need to return arrays of the subscribed email addresses:
    hw_companies = Company.find hw_comps
    hw_contacts = {}
    ['billing', 'general', 'technical'].each do |con_type|
      hw_contacts[con_type.to_sym] = []
      conditions = "is_#{con_type}_contact = 1"
      conditions += " AND is_subscribed = TRUE" if subscribers_only
      hw_companies.each do |hw_company| 
        hw_company.contacts.find(:all,
                                 :conditions => conditions).each do |con|
          if email_only
            hw_contacts[con_type.to_sym] << con.email
          else
            hw_contacts[con_type.to_sym] << con
          end
        end
      end
    end
    hosted_billing_contacts = {}
    hosted_comps.each do |hc|
      hosted_billing_contacts[hc[0]] = []
      Company.find(hc[1]).each do |comp|
        if email_only
          hosted_billing_contacts[hc[0]] << comp.contacts.find_billing_contact_addresses(subscribers_only)
        else
          hosted_billing_contacts[hc[0]] << comp.contacts.find_billing_contacts(subscribers_only)
        end
      end
      hosted_billing_contacts[hc[0]].flatten!
    end
    hosted_general_contacts = {}
    hosted_comps.each do |hc|
      hosted_general_contacts[hc[0]] = []
      Company.find(hc[1]).each do |comp|
        if email_only
          hosted_general_contacts[hc[0]] << comp.contacts.find_general_contact_addresses(subscribers_only)
        else
          hosted_general_contacts[hc[0]] << comp.contacts.find_general_contacts(subscribers_only)
        end
      end
      hosted_general_contacts[hc[0]].flatten!
    end
    hosted_technical_contacts = {}
    hosted_comps.each do |hc|
      hosted_technical_contacts[hc[0]] = []
      Company.find(hc[1]).each do |comp|
        if email_only
          hosted_technical_contacts[hc[0]] << comp.contacts.find_technical_contact_addresses(subscribers_only)
        else
          hosted_technical_contacts[hc[0]] << comp.contacts.find_technical_contacts(subscribers_only)
        end
      end
      hosted_technical_contacts[hc[0]].flatten!
    end
    hosted_contacts = {:billing => hosted_billing_contacts, :general => hosted_general_contacts,
                       :technical => hosted_technical_contacts}
    return hw_contacts, hosted_contacts
  end

end
