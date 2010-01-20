require File.dirname(__FILE__) + '/../test_helper'
require 'hardware_controller'

# Re-raise errors caught by the controller.
class HardwareController; def rescue_action(e) raise e end; end

class HardwareControllerTest < Test::Unit::TestCase
  def setup
    @controller = HardwareController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
