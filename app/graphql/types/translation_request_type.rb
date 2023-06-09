module Types
  class TranslationRequestType < BaseObject
    field :id, ID, null: false
    field :distant_key, String, null: false
    #field :created_at, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    #filed :translations, [TranslationType], null: true
    #field :body, String, null: false
    #field :team_id, Int, null: true
  end
end