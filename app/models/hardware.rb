# == Schema Information
# Schema version: 20100120120153
#
# Table name: hardware
#
#  id                   :integer(4)    not null, primary key
#  company_id           :integer(4)    not null
#  cabinet_id           :integer(4)    
#  name                 :string(255)   
#  description          :text          
#  starting_cabinet_bay :integer(4)    
#  u_size               :integer(4)    default(1)
#  mac_address          :string(255)   
#  model_number         :string(255)   
#  serial_number        :string(255)   
#  is_hostable          :boolean(1)    
#  hardware_type_id     :integer(4)    not null
#  created_at           :datetime      
#  updated_at           :datetime      
#  created_by           :integer(4)    
#  updated_by           :integer(4)    
#  connections          :string(255)   
#  is_active            :boolean(1)    default(true)
#  deactivated_on       :date          
#  asset_value          :decimal(8, 2) default(0.0)
#  asset_tag            :string(255)   
#

class Hardware < ActiveRecord::Base
  belongs_to :company
  belongs_to :cabinet
  belongs_to :hardware_type

  has_many :accounts, :order => 'domain_name, host_name'
  has_many :ip_addresses, :dependent => :nullify

  validates_numericality_of :u_size, :starting_cabinet_bay, :asset_value
  validates_presence_of :name
  validates_uniqueness_of :name, :on => :create
  validates_uniqueness_of :mac_address, :on => :create,
                          :if => Proc.new {|hw| !hw.mac_address.blank?}
  validates_uniqueness_of :starting_cabinet_bay, :scope => :cabinet_id

  def validate
    unless self.cabinet.space_available_for(self)
      errors.add(:starting_cabinet_bay, "is invalid")
      errors.add_to_base("This size of hardware will not fit in the selected cabinet bays")
    end
  end

  def before_create
    self.name.downcase!
  end

  def secure_url
    "https://" + self.name
  end

end
