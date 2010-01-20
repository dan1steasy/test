require File.dirname(__FILE__) + '/../test_helper'
require 'domainreg_controller'

# Re-raise errors caught by the controller.
class DomainregController; def rescue_action(e) raise e end; end

class DomainregControllerTest < Test::Unit::TestCase
  def setup
    @controller = DomainregController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
