require "test_helper"
class LinesControllerTest < ActionDispatch::IntegrationTest
  test "returns correct line" do
    get "/lines/1"
    assert_equal "THIS IS ASCII TEXT\n", @response.body
    assert_response :ok
  end
  test "returns 413 on out of file line" do
    get "/lines/9000"
    assert_equal "OUT OF FILE\n", @response.body
    assert_response :payload_too_large
  end
end
