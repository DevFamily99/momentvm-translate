require 'test_helper'

class TranslationRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @translation_request = translation_requests(:one)
  end

  test "should get index" do
    get translation_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_translation_request_url
    assert_response :success
  end

  test "should create translation_request" do
    assert_difference('TranslationRequest.count') do
      post translation_requests_url, params: { translation_request: { completed: @translation_request.completed, distant_key: @translation_request.distant_key } }
    end

    assert_redirected_to translation_request_url(TranslationRequest.last)
  end

  test "should show translation_request" do
    get translation_request_url(@translation_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_translation_request_url(@translation_request)
    assert_response :success
  end

  test "should update translation_request" do
    patch translation_request_url(@translation_request), params: { translation_request: { completed: @translation_request.completed, distant_key: @translation_request.distant_key } }
    assert_redirected_to translation_request_url(@translation_request)
  end

  test "should destroy translation_request" do
    assert_difference('TranslationRequest.count', -1) do
      delete translation_request_url(@translation_request)
    end

    assert_redirected_to translation_requests_url
  end
end
