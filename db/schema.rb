# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091104121728) do

  create_table "account_types", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "product_id"
    t.boolean "requires_hardware"
    t.boolean "requires_hosting"
  end

  create_table "accounts", :force => true do |t|
    t.integer  "company_id"
    t.string   "host_name"
    t.string   "domain_name"
    t.integer  "hardware_id"
    t.string   "secure_link"
    t.datetime "created_at"
    t.integer  "support_level_id"
    t.datetime "updated_at"
    t.integer  "account_type_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.boolean  "is_active",        :default => true
    t.date     "deactivated_on"
  end

  create_table "accounts_products", :id => false, :force => true do |t|
    t.integer "account_id", :null => false
    t.integer "product_id", :null => false
  end

  add_index "accounts_products", ["account_id"], :name => "index_accounts_products_on_account_id"
  add_index "accounts_products", ["product_id"], :name => "index_accounts_products_on_product_id"

  create_table "bandwidth_quotas", :force => true do |t|
    t.integer "account_id"
    t.float   "value"
  end

  create_table "cabinets", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "datacentre_id"
    t.integer "u_space"
  end

  create_table "categories", :force => true do |t|
    t.string "name"
  end

  create_table "companies", :force => true do |t|
    t.string  "name",                             :null => false
    t.string  "address1",                         :null => false
    t.string  "address2"
    t.string  "town"
    t.string  "county"
    t.string  "country"
    t.string  "postcode",                         :null => false
    t.string  "phone1"
    t.string  "phone2"
    t.string  "fax"
    t.string  "url"
    t.string  "vat_code"
    t.date    "created_at",                       :null => false
    t.integer "created_by"
    t.integer "updated_by"
    t.date    "updated_at"
    t.integer "old_id"
    t.boolean "is_active",      :default => true
    t.date    "deactivated_on"
  end

  create_table "companies_contacts", :id => false, :force => true do |t|
    t.integer "company_id"
    t.integer "contact_id"
  end

  create_table "contacts", :force => true do |t|
    t.string  "title",                :default => ""
    t.string  "forename"
    t.string  "phone1"
    t.string  "phone2"
    t.string  "fax"
    t.string  "email",                                  :null => false
    t.string  "position"
    t.boolean "is_subscribed",        :default => true, :null => false
    t.boolean "is_billing_contact",                     :null => false
    t.boolean "is_general_contact",                     :null => false
    t.boolean "is_technical_contact",                   :null => false
    t.date    "created_at",                             :null => false
    t.string  "surname"
    t.integer "created_by"
    t.integer "updated_by"
    t.date    "updated_at"
    t.integer "old_id"
    t.boolean "is_active",            :default => true
    t.date    "deactivated_on"
  end

  create_table "datacentres", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "cabinet_space"
  end

  create_table "disk_quotas", :force => true do |t|
    t.integer "account_id"
    t.float   "value"
  end

  create_table "domain_registrations", :force => true do |t|
    t.integer "company_id"
    t.string  "tld"
    t.string  "domain_name"
    t.integer "registrar_id"
    t.date    "renewal_date"
    t.integer "reg_period"
    t.date    "registration_date"
    t.date    "last_updated"
  end

  create_table "email_templates", :force => true do |t|
    t.string "subject"
    t.text   "html_body"
    t.string "template_name"
    t.text   "text_body"
  end

  create_table "hardware", :force => true do |t|
    t.integer  "company_id",                                                           :null => false
    t.integer  "cabinet_id"
    t.string   "name"
    t.text     "description"
    t.integer  "starting_cabinet_bay"
    t.integer  "u_size",                                             :default => 1
    t.string   "mac_address"
    t.string   "model_number"
    t.string   "serial_number"
    t.boolean  "is_hostable"
    t.integer  "hardware_type_id",                                                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "connections"
    t.boolean  "is_active",                                          :default => true
    t.date     "deactivated_on"
    t.decimal  "asset_value",          :precision => 8, :scale => 2, :default => 0.0
    t.string   "asset_tag"
  end

  create_table "hardware_types", :force => true do |t|
    t.string "name"
    t.string "colour"
    t.string "admin_url"
  end

  create_table "ip_addresses", :force => true do |t|
    t.string  "address",     :limit => 15, :null => false
    t.integer "company_id"
    t.integer "hardware_id"
  end

  create_table "key_tests", :force => true do |t|
    t.binary "encrypted_phrase"
  end

  create_table "licence_types", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "licences", :force => true do |t|
    t.integer "licence_type_id"
    t.date    "expires_on"
    t.boolean "in_use",          :default => false
    t.text    "value"
    t.integer "account_id"
    t.date    "created_on"
  end

  create_table "login_details", :force => true do |t|
    t.string  "description"
    t.binary  "encrypted_username"
    t.binary  "encrypted_password"
    t.string  "type"
    t.integer "account_id"
    t.integer "company_id"
    t.integer "contact_id"
    t.integer "registrar_id"
    t.date    "created_at"
    t.date    "updated_at"
    t.integer "created_by"
    t.integer "updated_by"
    t.text    "url"
  end

  create_table "notes", :force => true do |t|
    t.binary   "encrypted_note"
    t.datetime "created_at"
    t.integer  "created_by"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.string   "type"
    t.integer  "company_id"
    t.integer  "contact_id"
    t.integer  "account_id"
    t.boolean  "is_financial",   :default => false
  end

  create_table "order_items", :force => true do |t|
    t.integer "order_id"
    t.integer "product_id"
    t.float   "quantity"
    t.float   "percent_discount"
    t.integer "fixed_discount",   :limit => 10, :precision => 10, :scale => 0
    t.text    "description"
    t.integer "account_id"
  end

  create_table "orders", :force => true do |t|
    t.datetime "created_at"
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "contact_id"
    t.boolean  "is_complete"
  end

  create_table "power_quotas", :force => true do |t|
    t.integer "company_id"
    t.float   "value"
  end

  create_table "products", :force => true do |t|
    t.string  "code"
    t.string  "name"
    t.string  "description"
    t.integer "category_id"
    t.decimal "price",             :precision => 8, :scale => 2, :default => 0.0
    t.date    "created_on"
    t.boolean "requires_hardware"
    t.boolean "requires_hosting"
  end

  create_table "registrars", :force => true do |t|
    t.string  "name"
    t.string  "url"
    t.binary  "encrypted_username"
    t.binary  "encrypted_password"
    t.boolean "has_api"
    t.string  "valid_tlds"
  end

  create_table "schema_info", :id => false, :force => true do |t|
    t.integer "version"
  end

  create_table "ssls", :force => true do |t|
    t.integer "account_id",  :null => false
    t.text    "key"
    t.text    "request"
    t.text    "certificate"
  end

  create_table "support_levels", :force => true do |t|
    t.string "code"
    t.string "name"
    t.text   "description"
  end

  create_table "traffic_quotas", :force => true do |t|
    t.integer "company_id"
    t.float   "value"
  end

  create_table "users", :force => true do |t|
    t.string  "name"
    t.string  "real_name"
    t.string  "email"
    t.string  "password"
    t.string  "pin"
    t.binary  "key"
    t.integer "list_limit",    :default => 15
    t.boolean "is_in_finance", :default => false
  end

end
