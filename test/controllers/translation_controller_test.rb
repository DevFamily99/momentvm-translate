require 'test_helper'

class TranslationControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get translation_update_url
    assert_response :success
  end

end
