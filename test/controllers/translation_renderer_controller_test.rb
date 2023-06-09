require 'test_helper'

class TranslationRendererControllerTest < ActionDispatch::IntegrationTest
  test "should get translate_body" do
    get translation_renderer_translate_body_url
    assert_response :success
  end

end
