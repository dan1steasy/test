require File.dirname(__FILE__) + '/../test_helper'
require 'licence_types_controller'

# Re-raise errors caught by the controller.
class LicenceTypesController; def rescue_action(e) raise e end; end

class LicenceTypesControllerTest < Test::Unit::TestCase
  def setup
    @controller = LicenceTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
