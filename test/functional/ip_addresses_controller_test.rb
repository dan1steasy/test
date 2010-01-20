require File.dirname(__FILE__) + '/../test_helper'
require 'ip_addresses_controller'

# Re-raise errors caught by the controller.
class IpAddressesController; def rescue_action(e) raise e end; end

class IpAddressesControllerTest < Test::Unit::TestCase
  fixtures :ip_addresses

  def setup
    @controller = IpAddressesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = ip_addresses(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:ip_addresses)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:ip_address)
    assert assigns(:ip_address).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:ip_address)
  end

  def test_create
    num_ip_addresses = IpAddress.count

    post :create, :ip_address => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_ip_addresses + 1, IpAddress.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:ip_address)
    assert assigns(:ip_address).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      IpAddress.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      IpAddress.find(@first_id)
    }
  end
end
