# == Schema Information
# Schema version: 82
#
# Table name: products
#
#  id                :integer(11)   not null, primary key
#  code              :string(255)   
#  name              :string(255)   
#  description       :string(255)   
#  category_id       :integer(11)   
#  price             :decimal(8, 2) default(0.0)
#  created_on        :date          
#  requires_hardware :boolean(1)    
#  requires_hosting  :boolean(1)    
#

class Product < ActiveRecord::Base
  belongs_to :category

  has_and_belongs_to_many :accounts

  validates_presence_of     :code, :name, :price
  validates_numericality_of :price

  # Structure for use in 'product_list_by_category' method.
  ProductCategory = Struct.new(:id, :name)

  # Class for use in 'product_list_by_category' method.
  class ProductType
    attr_reader :type_name, :options
    def initialize(name)
      @type_name = name
      @options = []
    end
    def <<(option)
      @options << option
    end
  end

  def name_and_price
    nap = self.name + " (" + self.formatted_price + ")"
    return nap
  end

  def formatted_price
    fp = "£" + self.price.to_s
    return fp
  end

  def category_name
    self.category.name
  end

  # Enable the creation of an grouped selection list
  def self.product_list_by_category

    # Now create options for every category
    prod_list = []
    categories = Category.find :all, :order => 'name'
    categories.each do |category|
      prod_cat = ProductType.new(category.name.upcase)
      products = category.products.find :all, :select => 'id, name, code',
                                        :order => 'name'
      products.each do |product|
        prod_cat << ProductCategory.new(product.id, "#{product.name} (#{product.code})")
      end
      prod_list << prod_cat
    end
    prod_list
  end
end
