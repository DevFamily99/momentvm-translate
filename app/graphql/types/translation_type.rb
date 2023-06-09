module Types
  class TranslationType < BaseObject
    field :id, ID, null: false
    field :body, GraphQL::Types::JSON, null: false
    field :team_id, Int, null: true
    field :created_at, String, null: false
  end
end