require File.dirname(__FILE__) + '/../test_helper'

class CompanyTest < Test::Unit::TestCase
  fixtures :companies

  def setup
    @company = Company.find 1
  end

  # Replace this with your real tests.
  def test_create
    assert_kind_of Company, @company
    assert_equal 1, @company.id
    assert_equal "1st Easy Limited", @company.name
    assert_equal "Lower Washford Mill, Mill Street", @company.address1
    assert_equal "Buglawton", @company.address2
    assert_equal "Congleton", @company.town
    assert_equal "Cheshire", @company.county
    assert_equal "United Kingdom", @company.country
    assert_equal "CW12 2AD", @company.postcode
    assert_equal "01260 295 222", @company.phone1
    assert_equal nil, @company.phone2
    assert_equal nil, @company.fax
    assert_equal "http://www.1steasy.com", @company.url
    assert_equal nil, @company.vat_code
    assert_equal "2006-11-23", @company.created_at_before_type_cast
  end

end
