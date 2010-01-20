require File.dirname(__FILE__) + '/../test_helper'
require 'support_levels_controller'

# Re-raise errors caught by the controller.
class SupportLevelsController; def rescue_action(e) raise e end; end

class SupportLevelsControllerTest < Test::Unit::TestCase
  fixtures :support_levels

  def setup
    @controller = SupportLevelsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = support_levels(:first).id
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

    assert_not_nil assigns(:support_levels)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:support_level)
    assert assigns(:support_level).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:support_level)
  end

  def test_create
    num_support_levels = SupportLevel.count

    post :create, :support_level => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_support_levels + 1, SupportLevel.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:support_level)
    assert assigns(:support_level).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      SupportLevel.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      SupportLevel.find(@first_id)
    }
  end
end
