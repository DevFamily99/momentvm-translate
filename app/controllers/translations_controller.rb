#
#   This controller should not be modified. For API changes use translation_controller.rb
#
class TranslationsController < ApplicationController
  before_action :set_translation, only: [:show, :edit, :update, :destroy]

  # GET /translations
  # GET /translations.json
  def index
    @translations = Translation.all
  end

  # GET /translations/1
  # GET /translations/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @translation }
    end
  end

  # Deprecated
  def list
    translation_ids = params[:translations].split(',')
    translations = Translation.where(id: translation_ids)
    render json: {
      message: :ok,
      translations: translations,
      warnings: [
        {
          message: 'This API will be deprecated soon'
        }
      ]
    }
  end

  # GET /translations/new
  def new
    @translation = Translation.new
  end

  # GET /translations/1/edit
  def edit
    @yaml_body = @translation.body.to_yaml
  end

  # POST /translations
  # POST /translations.json
  def create
    @translation = Translation.new(translation_params)

    respond_to do |format|
      if @translation.save
        format.html { redirect_to @translation, notice: 'Translation was successfully created.' }
        format.json { render :show, status: :created, location: @translation }
      else
        format.html { render :new }
        format.json { render json: @translation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /translations/1
  # PATCH/PUT /translations/1.json
  def update
    # foo
    respond_to do |format|
      if @translation.update(translation_params)
        format.html { redirect_to @translation, notice: 'Translation was successfully updated.' }
        format.json { render :show, status: :ok, location: @translation }
      else
        format.html { render :edit }
        format.json { render json: @translation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /translations/1
  # DELETE /translations/1.json
  def destroy
    @translation.destroy
    respond_to do |format|
      format.html { redirect_to translations_url, notice: 'Translation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    query = params[:q] || ''
    team_id = params[:team_id]
    render json: Translation.where(team_id: team_id).where('body ILIKE ?', '%' + query + '%').limit(30)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_translation
    @translation = Translation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def translation_params
    params.require(:translation).permit!
  end
end
