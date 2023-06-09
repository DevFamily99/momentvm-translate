json.extract! translation_request, :id, :distant_key, :completed, :created_at, :updated_at
json.url translation_request_url(translation_request, format: :json)
