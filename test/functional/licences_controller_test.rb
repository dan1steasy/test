require File.dirname(__FILE__) + '/../test_helper'
require 'licences_controller'

# Re-raise errors caught by the controller.
class LicencesController; def rescue_action(e) raise e end; end

class LicencesControllerTest < Test::Unit::TestCase
  def setup
    @controller = LicencesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
