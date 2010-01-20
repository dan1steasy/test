# A class to be used when creating DCP accounts
class DcpAccount < ActiveRecord::Base
  DcpAccount.establish_connection :adapter => 'mysql',
                                  :host => 'secure.1steasy.com',
                                  :database => '1steasy-domains',
                                  :username => 'newstore',
                                  :password => '34BbwersTTT23'

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
end

# A DCP account has a user
class DcpUser < DcpAccount
  require 'digest/md5'
  set_table_name  'User'
  set_primary_key 'User_Id'

  #has_many :dcp_contacts, :dcp_profiles

  validates_uniqueness_of :User_Name

  def self.generate_user_name(desired_name)
    # Generate a user name, based on first name & last name
    # Usernames can only be 15 characters in this fucked up system...
    if desired_name.length > 15
      # Trim the username down to 15 characters
      user_name = desired_name[0..14]
    else
      user_name = desired_name
    end
    if DcpUser.find(:all, :conditions => ['User_Name LIKE ?', user_name]).length == 0
      return user_name
    else
      # If we found that username, call ourselves again, with a random number
      # appended to our last_name
      generate_user_name(rand(99).to_s + user_name)
    end
  end

  def self.generate_password
    password_chars = ('a'..'z').to_a + ('0'..'9').to_a
    ctr = 0
    password = ''
    while ctr < 12
      password << password_chars.rand
      ctr += 1
    end
    password
  end

  # We will create a user account by sending in a contact object
  def self.create_from_contact(contact, company=nil)
    if company.blank?
      company = contact.companies[0]
    end
    # Generate a user name
    user_name = DcpUser.generate_user_name(contact.forename.downcase.gsub(/\s/, '') +
                                           contact.surname.downcase.gsub(/\s/, ''))
    password = DcpUser.generate_password
    position = contact.position.blank? ? 'Owner' : contact.position
    # Create the DCP User account
    dcp_user = create!(:User_Name => user_name, :First_Name => contact.forename,
                       :Last_Name => contact.surname, :Position => position,
                       :Company => company.name, :Address1 => company.address1,
                       :Address2 => company.address2, :Town => company.town,
                       :County => company.county, :Postcode => company.postcode,
                       :Phone => company.phone1, :Email => contact.email,
                       :Password => Digest::MD5.hexdigest(password), :Country_Id => 826,
                       :Is_Confirmed => true, :Memory => 'domains', :Level => 2, :Admin => 0)
    return dcp_user, password
  end
end

# A DCP account has contacts
class DcpContact < DcpAccount
  set_table_name  'Contacts'
  set_primary_key 'Contact_Id'

  belongs_to :dcp_user, :foreign_key => 'User_Id'

  def self.create_from_contact(user, contact)
    create!(:User_Id => user.User_Id, :Title => contact.title, :First_Name => contact.forename,
            :Last_Name => contact.surname, :Phone1 => user.Phone, :Phone2 => contact.phone2,
            :Fax => contact.fax, :Email => contact.email, :Position => user.Position)
  end
end

# A DCP account has profiles
class DcpProfile < DcpAccount
  set_table_name  'Profiles'
  set_primary_key 'Profile_Id'

  belongs_to :dcp_user, :foreign_key => 'User_Id'

  def self.create_from_company(user, company)
    create!(:User_Id => user.User_Id, :Company => company.name, :Address1 => company.address1,
            :Address2 => company.address2, :Town => company.town, :County => company.county,
            :Postcode => company.postcode, :Country => COUNTRY_CODES[company.country])
  end
end
