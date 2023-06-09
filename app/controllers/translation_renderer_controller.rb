class TranslationRendererController < ApplicationController
  require 'markdown_renderer'

  # Accepts json body
  def translate_body
    body = request.body.read.force_encoding('UTF-8')
    locale = params[:locale]
    #locale = locale.gsub("_", "-")
    puts "===== locale: #{locale}"
    #puts body
    #puts "debug params: #{params.inspect}"

    body = body.gsub(/loc::([0-9]+)/) do


      loc = localization_for_locale($1, locale)


      if locale != "default"
        if loc.empty? && locale.include?("es-")
          loc = localization_for_locale($1, "es")
        elsif loc.empty? &&  locale.include?("zh-")
            loc = localization_for_locale($1, "zh")
        elsif loc.empty? &&  locale.include?("ru-")
            loc = localization_for_locale($1, "ru")
        elsif loc.empty? &&  locale.include?("it-")
            loc = localization_for_locale($1, "it")
        elsif loc.empty? &&  locale.include?("de-")
            loc = localization_for_locale($1, "de")
        elsif loc.empty? &&  locale.include?("fr-")
            loc = localization_for_locale($1, "fr")
        elsif loc.empty? &&  locale.include?("nl-")
            loc = localization_for_locale($1, "nl")
        elsif loc.empty? &&  locale.include?("no-")
          loc = localization_for_locale($1, "no")
        elsif locale == "en-GB" || loc.empty?
          loc = localization_for_locale($1, "default")
        end
      end

      #puts "locale: #{$1}, content: #{loc}"
      if loc =~ /[-|#|*|^]+/ # If contains markdown
        markdown = MarkdownRender.new
        loc = markdown.render(loc)
      end
      loc
    end
    render plain: body
  end

  def search_translations
    query = params[:query]
    if query.nil?
      render json: { error: "Query error" }
      return
    end
    translations = Translation.where("body like ?", "%#{query}%")
    render json: translations
  end


  private

  # The locale should be always de-DE so we can fall back to de
  def localization_for_locale(id, locale)
    #puts ">>> Translation. Translation #{id}, locale: #{locale}."
    translation = nil
    begin
      translation = Translation.find(id)
    rescue ActiveRecord::RecordNotFound
      return ""
    end
    #localizations = JSON.parse(translation.body)
    localizations = nil
    begin
      localizations = translation.body
    rescue Psych::SyntaxError
      return "Syntax incorrect"
    end
    localization = localizations[locale]
    if localization.nil? == false
      return localization
    end
    # Fallback to language
    lang = locale[/[a-z]{2}/]
    if localizations.key? lang
      return localizations[lang]
    end
    # Fallback to x-default
    if localizations.key? "default"
      return localizations["default"]
    end
    p "localizations is empty: #{localizations}"
    # Noting found at all
    return ""
  end


end
