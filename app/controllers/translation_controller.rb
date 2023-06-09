# require 'language_wire/assignment_document'
# require 'language_wire/assignment'
# require 'language_wire/project_request'
# require 'language_wire/project'
# require 'language_wire/translation_document'
# require 'language_wire/translation_frame'
require 'markdown_renderer'
#
#  The main interace for the API
class TranslationController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  before_action :check_team, only: [:update, :create]

  def root
    render plain: ''
  end

  def update
    translation = Translation.find(params[:id])
    if translation.team_id != params[:teamId].to_i
      puts 'Error. 401. team ID != params team ID'
      render status: 401, json: {
        errors: 'access not allowed'
      }
      return
    end
    translation.body = JSON.parse(request.raw_post)
    errors = []
    if translation.save
      render json: :ok
      nil
    else
      render status: 500, json: {
        errors: :count_not_save,
        translation: translation_path
      }
    end
  end

  # /api/translation/new
  def create
    translation = Translation.new
    translation.body = JSON.parse(request.raw_post)
    translation.team_id = params[:teamId]
    if translation.save
      render status: 200, json: {
        translation: translation,
        message: 'Created translation'
      }
    else
      render status: 422, json: {
        errors: translation.errors.full_messages
      }
    end
  end

  def destroy
    translation = Translation.find(params[:id])
    translation.destroy if translation.team_id == params[:teamId].to_i
  end

  # Find translations by ID and returns them
  def list
    content = JSON.parse(request.body.read.force_encoding('UTF-8'))
    translation_ids = content['translations'].map(&:to_i)
    translations = Translation.where(id: translation_ids)
    # puts translations.count
    render json: {
      message: :ok,
      translations: translations
    }
  end

  # First step in translation process
  # Requested by main app to send to validation
  # External API integration.
  # Returns a 202 if some translations were not found
  # Returns a 500 if there are no frames
  def send_to_translation_validation
    puts ':send_to_translation_validation'
    errors = []
    translations = []
    page_id = request.headers['Page-ID']
    if page_id.nil?
      puts 'Error: Page-ID header not set'
      render status: 400, json: { message: 'Page-ID header not set' }
      return
    end
    body = request.raw_post
    puts "request body: #{body}"
    document = LwTranslationDocument.new
    # Get all translations from the request body
    document.frames, errors = helpers.frames_from_body(body)
    errors.map { |err| puts err } unless errors.empty?
    puts errors if errors.empty? == false
    puts "Frames found: #{document.frames.count}"
    if document.frames.count == 0
      puts 'no translations found'
      render status: 404, json: {
        error: 'Document count is zero'
      }
      return
    end
    document.send_and_validate do |_error|
      if errors.empty?
        render json: {
          message: 'ok',
          document_id: document.distant_key
        }
        return
      else
        puts ':send_to_translation_validation, partial success'
        puts "These translations were not found: #{errors}"
        render status: 202, json: {
          message: 'Some translations were not found',
          errors: errors,
          created_frames: document.frames
        }
        return
      end
    end
  end

  # used for products on the pim
  # TODO refactor this so its more generic
  def create_and_validate_product_docs
    valid_products = []
    invalid_products = []
    products = product_params[:products]
    fields = product_params[:fields]
    # check if existing translations have been changed
    # p products, fields
    products.each do |product|
      document = create_and_validate_single_product(product, fields)
      if document
        valid_products << { product: product, document: document }
      else
        invalid_products << product
      end
    end
    render json: { validProducts: valid_products, invalidProducts: invalid_products }
  end

  # move to helper
  def create_and_validate_single_product(product, fields)
    document = LwTranslationDocument.new

    document.frames, errors = helpers.frames_from_product(product, fields)
    puts errors if errors.empty? == false
    puts document.frames.count
    return false if document.frames.count == 0

    document.send_and_validate do |_error|
      if errors.empty?
        return document
      else
        puts ':send_to_translation_validation, partial success'
        puts "These translations were not found: #{errors}"

        return false
      end
    end
  end

  # A Project is a wrapper for translations (documents) to be translated
  # The correlation_id is the pointer that the external API uses to find that project
  # Second and last step in translation process
  def create_project
    puts ':create_project'
    begin
      request_body = JSON.parse(request.body.read)
    rescue JSON::ParserError
      puts "JSON parsing error. Request: #{request.body.read}"
      logger.debug request.inspect
      logger.debug request.body
      render status: 500, json: { error: :json_parsing_error }
      return
    end
    documents = request_body['documents']
    target_locales = request_body['target_locales']
    briefing = request_body['briefing']
    deadline = request_body['deadline']
    project_title = request_body['project_title']
    puts "Briefing: #{briefing}"
    puts "Documents: #{documents}. #{JSON.parse(request.body.read)}."
    translation_request = TranslationRequest.new # Class persisted in the app
    project = LwProject.new
    project.correlation_id = Random.new_seed
    project.target_languages = target_locales
    project.briefing = briefing
    project.deadline = deadline
    project.title = project_title
    puts "correlation_id: #{project.correlation_id}"
    project.source_documents = documents
    project.create do |error_response|
      if error_response.nil? == false
        puts "LwProject creation error. #{error_response}"
        render status: 400, json: { message: 'LwProject creation error', error: error_response }
        return
      end
      translation_request.distant_key = project.correlation_id
      if translation_request.save
        puts 'Saved project'
        puts "translation request: #{translation_request.id}"
        render json: {
          message: 'ok',
          correlation_id: project.correlation_id,
          translation_request: translation_request.id
        }
      else
        puts 'Couldnt save project'
        render status: 500, json: { message: 'couldnt save project' }
      end
    end
  end

  def create_pim_project
    puts 'Create project'
    # get translation ids from products
    products = product_params[:products]
    documentIds = products.map { |product| product['translationDocumentKey'] }
    documentIds = documentIds.reject(&:nil?)
    documentIds = documentIds.map(&:to_i)
    # translationIds = products.map { |product| product['translationIds'] }.flatten.map { |translation| translation['translationId'] }
    # translations = Translation.find(translationIds)
    translation_request = TranslationRequest.new # Class persisted in the app
    project = LwProject.new
    project.correlation_id = Random.new_seed
    project.briefing = 'test'
    project.target_languages = product_params[:targetLanguages]
    project.deadline = product_params[:deadline]
    project.source_documents = documentIds
    project.create do |error_response|
      if error_response.nil? == false
        puts "LwProject creation error. #{error_response}"
        render status: 400, json: { message: 'LwProject creation error', error: error_response }
        return
      end
      translation_request.distant_key = project.correlation_id
      if translation_request.save
        puts 'Saved project'
        render json: { message: 'ok' }
      else
        puts 'Couldnt save project'
        render status: 500, json: { message: 'couldnt save project' }
      end
    end
  end

  def product_params
    hash = {}
    product_keys = params[:translation][:products].first.try(:keys).map do |key|
      hash[key.to_sym] = {}
    end

    params.require(:translation).permit(:deadline, targetLanguages: [], products: [:_id, :translationDocumentKey, :originId, hash, translationIds: %i[translationId SFCCId field]], fields: []).to_h
  end

  private

  def not_found
    render status: 404, json: { error: 'Team can not be found' }
  end

  def check_team
    Team.find params[:teamId].to_i
  end
end
