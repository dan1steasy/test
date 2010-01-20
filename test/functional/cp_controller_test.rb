require File.dirname(__FILE__) + '/../test_helper'
require 'cp_controller'

# Re-raise errors caught by the controller.
class CpController; def rescue_action(e) raise e end; end

class CpControllerTest < Test::Unit::TestCase
  def setup
    @controller = CpController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
