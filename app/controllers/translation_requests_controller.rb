# require "language_wire/assignment_document"
# require "language_wire/assignment"
# require "language_wire/project_request"
# require "language_wire/project"
# require "language_wire/translation_document"
# require "language_wire/translation_frame"

class TranslationRequestsController < ApplicationController
  before_action :set_translation_request, only: [:fetch_translations_for_req, :check_status, :show, :edit, :update, :destroy]
  # skip_before_action :verify_authenticity_token, only: :destroy

  # Generic, no input params
  def fetch_translations
    messages = []
    # translation_requests = [TranslationRequest.where(completed: nil).first]
    translation_requests = [TranslationRequest.all.order(updated_at: :desc).first]
    puts "#{translation_requests.count} open translation requests"
    translation_requests.each do |tr|
      puts "processing #{tr.distant_key}, created: #{tr.created_at}"
      tr.fetch_translation do |message|
        messages << message
      end
    end
    render json: { message: messages }
  end

  # Controller action for a single one
  def fetch_translations_for_req
    messages = []
    p ":fetch_translations_for_req #{@translation_request.distant_key}"
    # render plain: @translation_request.completed
    # return
    @translation_request.fetch_translation do |message|
      messages << message
    end
    # No errors
    if messages.empty?
      @translation_request.completed = DateTime.now if messages.empty?
      @translation_request.save
    end
    render json: { message: messages }
  end

  # fetch the LW translaiton project and check its status
  def check_status
    project_request = LwProjectRequest.new(corelation_id: @translation_request.distant_key)
    project_request.get_pending_projects do |response|
      return render json: { message: 'error from languagewire' }, status: 500 if response.nil?

      pending_projects = JSON.parse(response.body)
      project = pending_projects.find { |project| project['correlationId'] == @translation_request.distant_key }
      return render json: { message: 'Project translation ready', status: 'READY' } if project.nil?

      render json: { message: 'Project translation pending', status: 'PENDING' }
    end
  end

  # GET /translation_requests
  # GET /translation_requests.json
  def index
    @translation_requests = TranslationRequest.all.order(updated_at: :desc)
  end

  # GET /translation_requests/1
  # GET /translation_requests/1.json
  def show; end

  # GET /translation_requests/new
  def new
    @translation_request = TranslationRequest.new
  end

  # GET /translation_requests/1/edit
  def edit; end

  # POST /translation_requests
  # POST /translation_requests.json
  def create
    @translation_request = TranslationRequest.new(translation_request_params)

    respond_to do |format|
      if @translation_request.save
        format.html { redirect_to @translation_request, notice: 'Translation request was successfully created.' }
        format.json { render :show, status: :created, location: @translation_request }
      else
        format.html { render :new }
        format.json { render json: @translation_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /translation_requests/1
  # PATCH/PUT /translation_requests/1.json
  def update
    respond_to do |format|
      if @translation_request.update(translation_request_params)
        format.html { redirect_to @translation_request, notice: 'Translation request was successfully updated.' }
        format.json { render :show, status: :ok, location: @translation_request }
      else
        format.html { render :edit }
        format.json { render json: @translation_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /translation_requests/1
  # DELETE /translation_requests/1.json
  def destroy
    @translation_request.destroy
    respond_to do |format|
      format.html { redirect_to translation_requests_url, notice: 'Translation request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_translation_request
    @translation_request = TranslationRequest.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def translation_request_params
    params.require(:translation_request).permit(:distant_key, :completed)
  end
end
