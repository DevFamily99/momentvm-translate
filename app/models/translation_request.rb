class TranslationRequest < ApplicationRecord
  # Use a LwProjectRequest to fetch a project.
  # If the project is completed, get their content and update the translations
  def fetch_translation
    puts 'TranslationRequest fetch_translation'
    proj = LwProjectRequest.new
    proj.correlation_id = distant_key
    proj.retrieve_parse_project do |error|
      unless error.nil?
        p "Error in LwProjectRequest. #{error}"
        return
      end
      p "Assignments: #{proj.assignments.count}"
      # LwAssignmentDocument
      proj.assignments.each do |assignment|
        puts assignment.target_language.to_s
        assignment.documents.each do |document|
          get_document(document, assignment)
        end
      end
    end
    yield "#{proj.assignments.count} updates"
  end

  # LwAssignmentDocument, LwAssignment
  def get_document(document, assignment)
    translations_updated = 0

    if document.ready?
      puts "ready #{document.delivered_document} frames: #{document.frames.count}"
      document.get_content do |error|
        puts "Error: #{error}" if error
        next unless error.nil?

        document.frames.each do |frame|
          # p "frame: #{frame.inspect}"
          next if frame.metadata.nil?

          translation = nil
          begin
            translation = Translation.find(frame.metadata['translation_id'])
          rescue ActiveRecord::RecordNotFound
            puts "Translation #{frame.metadata['translation_id']} not found"
          end
          next if translation.nil?

          body = translation.body

          dw_locale = case assignment.target_language
                      when 'da'
                        'da-DK'
                      when 'de-DE'
                        'de'
                      when 'es-ES'
                        'es'
                      when 'fr-FR'
                        'fr'
                      when 'it-IT'
                        'it'
                      when 'ja'
                        'ja-JP'
                      when 'ko'
                        'ko-KR'
                      when 'nb'
                        'no'
                      when 'pl'
                        'pl-PL'
                      when 'nl-NL'
                        'nl'
                      when 'tr'
                        'tr-TR'
                      when 'zh-HK'
                        'zh'
                      else
                        assignment.target_language
                      end
          # if body[dw_locale] == ""
          body[dw_locale] = frame.text.unescape_trademarks
          body[dw_locale] = style_strong_tags(body[dw_locale])
          translation.body = body
          puts "translation #{translation.id} updated with #{assignment.target_language}" if translation.save
          translations_updated += 1
          # end
        end
      end
    end
    puts "Updated #{translations_updated} translations."
  end

  private

  def style_strong_tags(text)
    text.gsub('<strong>', '<strong style="font-weigth: 700; color: unset;">')
  end
end
