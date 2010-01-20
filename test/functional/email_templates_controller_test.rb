require File.dirname(__FILE__) + '/../test_helper'
require 'email_templates_controller'

# Re-raise errors caught by the controller.
class EmailTemplatesController; def rescue_action(e) raise e end; end

class EmailTemplatesControllerTest < Test::Unit::TestCase
  def setup
    @controller = EmailTemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
