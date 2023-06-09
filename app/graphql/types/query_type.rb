module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :translations, [TranslationType], null: false
    def translations
      #current_user = context[:current_user]
      Translation.last(100)
    end

    field :translation, TranslationType, null: false do
      argument :id, ID, required: true
      #   argument :name, String, required: false,
      #   argument :description String, required: false
    end
    def translation(id:)
      puts 'get translation gql'
      #puts CountryGroup.find(id).countries.inspect
      Translation.find(id)
    end

    field :translation_requests, [TranslationRequestType], null: false do
      argument :sort, String, required: false
    end
    def translation_requests(**_args)
      #current_user = context[:current_user]
      if _args[:sort] == "desc"
        TranslationRequest.order(created_at: :desc).limit(100)
      else
        TranslationRequest.last(100)
      end
    end

    field :translation_request, TranslationRequestType, null: false do
      argument :id, ID, required: true
      #   argument :name, String, required: false,
      #   argument :description String, required: false
    end
    def translation_request(id:)
      #puts CountryGroup.find(id).countries.inspect
      TranslationRequest.find(id)
    end





    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end
  end
end
