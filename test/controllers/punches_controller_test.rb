require "test_helper"

class PunchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get punches_index_url
    assert_response :success
  end
end
