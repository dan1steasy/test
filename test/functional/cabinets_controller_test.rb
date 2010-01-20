require File.dirname(__FILE__) + '/../test_helper'
require 'cabinets_controller'

# Re-raise errors caught by the controller.
class CabinetsController; def rescue_action(e) raise e end; end

class CabinetsControllerTest < Test::Unit::TestCase
  def setup
    @controller = CabinetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
