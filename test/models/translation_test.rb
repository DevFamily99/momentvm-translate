require 'test_helper'

class TranslationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "validation" do
    translations = [Translation.first, Translation.last]
    assert translation.count != 0
    
  end
end
