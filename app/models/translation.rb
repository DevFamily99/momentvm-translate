# frozen_string_literal: true

class Translation < ApplicationRecord
  belongs_to :team
  store :body, accessors: [:object_body], coder: YAML

  def raw_body
    read_attribute_before_type_cast('body')
  end

end
