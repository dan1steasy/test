require File.dirname(__FILE__) + '/../test_helper'
require 'login_details_controller'

# Re-raise errors caught by the controller.
class LoginDetailsController; def rescue_action(e) raise e end; end

class LoginDetailsControllerTest < Test::Unit::TestCase
  def setup
    @controller = LoginDetailsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
