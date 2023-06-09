# frozen_string_literal: true

module TranslationHelper
  def frames_from_body(body)
    # returns translation_frames, errors
    errors = []
    frames = []
    body.split(',').each do |translation_id|
      translation_id = translation_id.gsub('loc::', '')
      # body = body.gsub(/loc::([0-9]+)/) do
      # We could check if translated e.g. check for a foreign lang key
      begin
        translation = Translation.find(translation_id)
      rescue ActiveRecord::RecordNotFound
        errors << {
          error: :not_found,
          translation_id: translation_id
        }
        next
      end
      # counts how many localizations exist in a given translation body
      frame = LwTranslationFrame.new
      frame.text = translation.body['default']
      next if frame.text.nil?
      next if frame.text.empty?
      # If there is no text we skip it
      next if frame.text[/[a-zA-Z]+/].nil?

      frame.metadata = { translation_id: translation.id.to_s }
      frames << frame
      # document.add_content translation.body["default"]
    end
    [frames, errors]
  end

  def frames_from_product(product, fields)
    errors = []
    frames = []
    fields.each_with_index do |product_field, _i|
      next if product[product_field].nil?

      translationInfo = product['translationIds']&.find { |tr| tr['field'] == product_field }
      translationId = translationInfo['translationId'] if translationInfo
      begin
        translation = Translation.find(translationId) if translationId
      rescue StandardError
        translation = false
      end
      if translation

        translation.body = product[product_field]
        translation.save
        frame = LwTranslationFrame.new
        linebreak = '<span data-linebreak></span>'.to_json.gsub('"', '')
        trademark_r = '\\u003csup\\u003e\\u003csmall\\u003e®\\u003c/small\\u003e\\u003c/sup\\u003e'
        trademark_tm = '\\u003csup\\u003e\\u003csmall\\u003e™\\u003c/small\\u003e\\u003c/sup\\u003e'

        frame.text = product[product_field]['default'].gsub(trademark_r, '__TRADEMARK-R__').gsub(trademark_tm, '__TRADEMARK-TM__').gsub('\n', linebreak)
        frame.metadata = { translationId: translation.id.to_s, SFCCId: product['originId'], field: product_field }
        frames << frame

      else
        new_translation = Translation.new(team_id: 1, body: product[product_field])
        new_translation.save
        frame = LwTranslationFrame.new
        linebreak = '<span data-linebreak></span>'.to_json.gsub('"', '')
        trademark_r = '®'
        trademark_tm = '™'

        frame.text = product[product_field]['default'].gsub(trademark_r, '__TRADEMARK-R__').gsub(trademark_tm, '__TRADEMARK-TM__').gsub('\n', linebreak).force_encoding('utf-8')
        frame.metadata = { translationId: new_translation.id.to_s, SFCCId: product['originId'], field: product_field }
        frames << frame
      end
    end

    [frames, errors]
  end
end

###### TODO finalize this and check why frames are not created
