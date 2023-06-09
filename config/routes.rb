Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  post '/graphql', to: 'graphql#execute'
  root to: 'translation#root'

  resources :translation_requests do
    post 'fetch_translations_for_req', on: :member
    # Not specific to a singular one
    get 'fetch_translations', on: :collection
    get 'check_status', on: :member
  end
  # get 'translation/update'

  # Translate a html body
  post 'translate_body', to: 'translation_renderer#translate_body'
  
  # Search for a translation
  get 'api/translation/search', to: 'translations#search'
  
  # Integrates with API
  post 'api/send_to_translation_validation', to: 'translation#send_to_translation_validation'

  post 'api/create_and_validate_product_docs', to: 'translation#create_and_validate_product_docs'

  # Send multiple documents to create a project
  post 'api/create_project', to: 'translation#create_project'

  # Create a new team
  post 'api/create_team', to: 'teams#create'

  # Create a pim project
  post 'api/create_pim_project', to: 'translation#create_pim_project'

  get 'api/test/translation/:id/for_locale/:locale', to: 'translation_renderer#test_translation'
  # Retrieve a single translation
  get 'api/translation/:id', to: 'translation#show_translation'
  
  post 'api/team/:teamId/translation/:id/update', to: 'translation#update'

  post 'api/team/:teamId/translation/new', to: 'translation#create'
  # post 'api/translation/new', to: 'translation#create'

  delete 'api/team/:teamId/translation/:id', to: 'translation#destroy'

  get 'api/fixtranslation', to: 'translation#fix'

  resources :translations do
    get 'list/:translations', action: :list, on: :collection
  end

  scope :api do
    scope :translations do
      post 'list', to: 'translation#list'
    end
  end
end
