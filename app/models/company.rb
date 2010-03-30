# == Schema Information
# Schema version: 20100208131342
#
# Table name: companies
#
#  id             :integer(4)    not null, primary key
#  name           :string(255)   not null
#  address1       :string(255)   not null
#  address2       :string(255)   
#  town           :string(255)   
#  county         :string(255)   
#  country        :string(255)   
#  postcode       :string(255)   not null
#  phone1         :string(255)   
#  phone2         :string(255)   
#  fax            :string(255)   
#  url            :string(255)   
#  vat_code       :string(255)   
#  created_at     :date          not null
#  created_by     :integer(4)    
#  updated_by     :integer(4)    
#  updated_at     :date          
#  old_id         :integer(4)    
#  is_active      :boolean(1)    default(true)
#  deactivated_on :date          
#

class Company < ActiveRecord::Base
  require_dependency 'note'

  has_and_belongs_to_many :contacts
  has_many :company_notes,  :dependent => :destroy
  has_many :accounts,       :dependent => :destroy, :order => "domain_name, host_name"
  has_many :ip_addresses,   :dependent => :nullify
  has_many :domain_registrations
  has_one  :power_quota,    :dependent => :destroy
  has_one  :traffic_quota,  :dependent => :destroy

  validates_presence_of   :name, :address1, :phone1
  validates_presence_of   :postcode, :if => :country_is_uk?
  validates_uniqueness_of :name
  #validates_format_of     :postcode,
  #                        #:with => /^(([A-PR-WYZ]{1,2}[0-9]{1,2}[ABEHJMNPRVWXY]?)\s?([0-9][ABD-HJLNP-UW-Z]{2})|(GIR)\s?(0AA))$/,
  #                        :with => /^(GIR 0AA|[A-PR-UVWYZ]([0-9]{1,2}|([A-HK-Y][0-9]|[A-HK-Y][0-9]([0-9]|[ABEHMNPRV-Y]))|[0-9][A-HJKS-UW]) [0-9][ABD-HJLNP-UW-Z]{2})$/,
  #                        :if => :country_is_uk?
  validates_each :phone1, :phone2, :fax do |model, attribute, value|
    if(value !~ /^[0-9 ()\+\-\.]+$/) and (value != '') and (value != nil)
      model.errors.add(attribute, "is invalid")
    end
  end

  def before_validation
    self.postcode.upcase!
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

  def total_bandwidth_quota
    bandwidth_total = 0
    self.accounts.each do |account|
      if account.bandwidth_quota.blank?
        bandwidth_quota_value = 0
      elsif account.bandwidth_quota.value == nil
        bandwidth_quota_value = 0
      else
        bandwidth_quota_value = account.bandwidth_quota.value
      end
      bandwidth_total += bandwidth_quota_value
    end
    bandwidth_total.to_s + BandwidthQuota::UNIT
  end

  def total_disk_quota
    disk_quota_total = 0
    self.accounts.each do |account|
      if account.disk_quota.blank?
        disk_quota_value = 0
      elsif account.disk_quota.value == nil
        disk_quota_value = 0
      else
        disk_quota_value = account.disk_quota.value
      end
      disk_quota_total += disk_quota_value
    end
    disk_quota_total.to_s + DiskQuota::UNIT
  end

  def total_traffic_quota
    if self.traffic_quota.blank?
      "0" + TrafficQuota::UNIT
    else
      self.traffic_quota.value.to_s + TrafficQuota::UNIT
    end
  end

  def total_power_quota
    if self.power_quota.blank?
      "0 " + PowerQuota::UNIT
    else
      self.power_quota.value.to_s + " " + PowerQuota::UNIT
    end
  end

  def allocated_ip_networks
    IpAddress.find_networks(self)
  end

  def created_by_user
    User.find(self.created_by).name
  end

  private
  def country_is_uk?
    if self.country == "United Kingdom"
      true
    else
      false
    end
  end

  def create_old
    old_company = OldCompany.create_from_new self
    self.update_attribute(:old_id, old_company.id)
  end

  def update_old
    unless self.old_id.blank?
      old_company = OldCompany.find(self.old_id)
      old_company.update_from_new self
    end
  end

  def destroy_old
    unless self.old_id.blank?
      OldCompany.find(self.old_id).destroy
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

class OldCompany < OldAE
  set_table_name 'Companies'
  set_primary_key 'Company_Id'

  COUNTRY_CODES = {"Afghanistan" => "AF", "Albania" => "AL", "Algeria" => "DZ",
    "American Samoa" => "AS", "Andorra" => "AD", "Angola" => "AO", "Anguilla" => "AI",
    "Antarctica" => "AQ", "Antigua And Barbuda" => "AG", "Argentina" => "AR",
    "Armenia" => "AM", "Aruba" => "AW", "Australia" => "AU", "Austria" => "AT",
    "Azerbaijan" => "AZ", "Bahamas" => "BS", "Bahrain" => "BH", "Bangladesh" => "BD",
    "Barbados" => "BB", "Belarus" => "BY", "Belgium" => "BE", "Belize" => "BZ",
    "Benin" => "BJ", "Bermuda" => "BM", "Bhutan" => "BT", "Bolivia" => "BO",
    "Bosnia and Herzegowina" => "BA", "Botswana" => "BW", "Bouvet Island" => "BV",
    "Brazil" => "BR", "British Indian Ocean Territory" => "IO",
    "Brunei Darussalam" => "BN", "Bulgaria" => "BG", "Burkina Faso" => "BF",
    "Burma" => "MM", "Burundi" => "BI", "Cambodia" => "KH", "Cameroon" => "CM",
    "Canada" => "CA", "Cape Verde" => "CV", "Cayman Islands" => "KY",
    "Central African Republic" => "CF", "Chad" => "TD", "Chile" => "CL",
    "China" => "CN", "Christmas Island" => "CX", "Cocos (Keeling) Islands" => "CC",
    "Colombia" => "CO", "Comoros" => "KM", "Congo" => "CG",
    "Congo, the Democratic Republic of the" => "CD", "Cook Islands" => "CK",
    "Costa Rica" => "CR", "Cote d'Ivoire" => "CI", "Croatia" => "HR", "Cuba" => "CU",
    "Cyprus" => "CY", "Czech Republic" => "CZ", "Denmark" => "DK", "Djibouti" => "DJ",
    "Dominica" => "DM", "Dominican Republic" => "DO", "East Timor" => "TP",
    "Ecuador" => "EC", "Egypt" => "EG", "El Salvador" => "SV",
    "Equatorial Guinea" => "GQ", "Eritrea" => "ER", "Espana" => "ES",
    "Estonia" => "EE", "Ethiopia" => "ET", "Falkland Islands" => "FK",
    "Faroe Islands" => "FO", "Fiji" => "FJ", "Finland" => "FI", "France" => "FR",
    "French Guiana" => "GF", "French Polynesia" => "PF",
    "French Southern Territories" => "TF", "Gabon" => "GA", "Gambia" => "GM",
    "Georgia" => "GE", "Germany" => "DE", "Ghana" => "GH", "Gibraltar" => "GI",
    "Greece" => "GR", "Greenland" => "GL", "Grenada" => "GD",
    "Guadeloupe" => "GP", "Guam" => "GU", "Guatemala" => "GT", "Guinea" => "GN",
    "Guinea-Bissau" => "GW", "Guyana" => "GY", "Haiti" => "HT",
    "Heard and Mc Donald Islands" => "HM", "Honduras" => "HN", "Hong Kong" => "HK",
    "Hungary" => "HU", "Iceland" => "IS", "India" => "IN", "Indonesia" => "ID",
    "Ireland" => "IE", "Israel" => "IL", "Italy" => "IT", "Iran" => "IR",
    "Iraq" => "IQ", "Jamaica" => "JM", "Japan" => "JP", "Jordan" => "JO",
    "Kazakhstan" => "KZ", "Kenya" => "KE", "Kiribati" => "KI",
    "Korea, Republic of" => "KR", "Korea (South)" => "KP", "Kuwait" => "KW",
    "Kyrgyzstan" => "KG", "Lao People's Democratic Republic" => "LA", "Latvia" => "LV",
    "Lebanon" => "LB", "Lesotho" => "LS", "Liberia" => "LR", "Liechtenstein" => "LI",
    "Lithuania" => "LT", "Luxembourg" => "LU", "Macau" => "MO", "Macedonia" => "MK",
    "Madagascar" => "MG", "Malawi" => "MW", "Malaysia" => "MY", "Maldives" => "MV",
    "Mali" => "ML", "Malta" => "MT", "Marshall Islands" => "MH", "Martinique" => "MQ",
    "Mauritania" => "MR", "Mauritius" => "MU", "Mayotte" => "YT", "Mexico" => "MX",
    "Micronesia, Federated States of" => "FM", "Moldova, Republic of" => "MD",
    "Monaco" => "MC", "Mongolia" => "MN", "Montserrat" => "MS", "Morocco" => "MA",
    "Mozambique" => "MZ", "Myanmar" => "MM", "Namibia" => "NA", "Nauru" => "NR",
    "Nepal" => "NP", "Netherlands" => "NL", "Netherlands Antilles" => "AN",
    "New Caledonia" => "NC", "New Zealand" => "NZ", "Nicaragua" => "NI",
    "Niger" => "NE", "Nigeria" => "NG", "Niue" => "NU", "Norfolk Island" => "NF",
    "Northern Mariana Islands" => "MP", "Norway" => "NO",
    "Oman" => "OM", "Pakistan" => "PK", "Palau" => "PW", "Panama" => "PA",
    "Papua New Guinea" => "PG", "Paraguay" => "PY", "Peru" => "PE",
    "Philippines" => "PH", "Pitcairn" => "PN", "Poland" => "PL", "Portugal" => "PT",
    "Puerto Rico" => "PR", "Qatar" => "QA", "Reunion" => "RE", "Romania" => "RO",
    "Russia" => "RU", "Rwanda" => "RW", "Saint Kitts and Nevis" => "KN",
    "Saint Lucia" => "LC", "Saint Vincent and the Grenadines" => "VC",
    "Samoa (Independent)" => "WS", "San Marino" => "SM",
    "Sao Tome and Principe" => "ST", "Saudi Arabia" => "SE", 
    "Senegal" => "SN", "Serbia and Montenegro" => "YU", "Seychelles" => "SC",
    "Sierra Leone" => "SL", "Singapore" => "SG", "Slovakia" => "SK",
    "Slovenia" => "SI", "Solomon Islands" => "SB", "Somalia" => "SO",
    "South Africa" => "ZA", "South Georgia and the South Sandwich Islands" => "GS",
    "South Korea" => "KP", "Spain" => "ES", "Sri Lanka" => "LK", "St. Helena" => "SH",
    "St. Pierre and Miquelon" => "PM", "Suriname" => "SR",
    "Svalbard and Jan Mayen Islands" => "SJ", "Swaziland" => "SZ", "Sweden" => "SE",
    "Switzerland" => "CH", "Taiwan" => "TW", "Tajikistan" => "TJ", "Tanzania" => "TZ",
    "Thailand" => "TH", "Togo" => "TG", "Tokelau" => "TK", "Tonga" => "TO",
    "Trinidad" => "TT", "Trinidad and Tobago" => "TT", "Tunisia" => "TN",
    "Turkey" => "TR", "Turkmenistan" => "TM", "Turks and Caicos Islands" => "TC",
    "Tuvalu" => "TV", "Uganda" => "UG", "Ukraine" => "UA",
    "United Arab Emirates" => "AE", "United Kingdom" => "GB", "United States" => "US",
    "United States Minor Outlying Islands" => "UM", "Uruguay" => "UY",
    "Uzbekistan" => "UZ", "Vanuatu" => "VU", "Vatican City State (Holy See)" => "VA",
    "Venezuela" => "VE", "Viet Nam" => "VN", "Virgin Islands (British)" => "VG",
    "Virgin Islands (U.S.)" => "VI", 
    "Wallis and Futuna Islands" => "WF", "Western Sahara" => "EH", "Yemen" => "YE",
    "Zambia" => "AM", "Zimbabwe" => "ZW"}

  def self.create_from_new(company)
    town = company.town || 'None'
    phone = company.phone1 || '00000'
    OldCompany.create!(:Company => company.name, :Address1 => company.address1,
                       :Address2 => company.address2, :Town => town,
                       :County => company.county, :Postcode => company.postcode,
                       :Country => COUNTRY_CODES[company.country],
                       :Company_Phone => phone)
  end

  def update_from_new(company)
    town = company.town || 'None'
    phone = company.phone1 || '00000'
    self.update_attributes(:Company => company.name, :Address1 => company.address1,
                           :Address2 => company.address2, :Town => town,
                           :County => company.county, :Postcode => company.postcode,
                           :Country => COUNTRY_CODES[company.country],
                           :Company_Phone => phone)
  end

  def copy_to_new
    if self.Company_Phone.blank?
      phone1 = "0000"
    else
      phone1 = self.Company_Phone
    end
    company = Company.create!(:name => self.Company, :address1 => self.Address1,
                              :address2 => self.Address2, :town => self.Town,
                              :county => self.County, :postcode => self.Postcode,
                              :phone1 => phone1,
                              :country => COUNTRY_CODES.index(self.Country) || "United Kingdom",
                              :created_by => 1, :old_id => self.id)
  end
end

class VTiger < ActiveRecord::Base
  VTiger.establish_connection configurations['vtiger']
end

class VTCompany < VTiger
  set_table_name  'vtiger_account'
  set_primary_key 'accountid'
end
