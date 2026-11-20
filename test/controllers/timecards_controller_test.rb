require "test_helper"

class TimecardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get timecards_index_url
    assert_response :success
  end
end
