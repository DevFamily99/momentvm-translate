# Custom Markdown Renderer
class MarkdownRender


    def render(text)
        
        text = text.gsub(/\*\*(.*)\*\*/, "<strong>\\1</strong>")    # bold
            .gsub(/\^r/, "<sup><small>®</small></sup>")             # registered trademark sign
            .gsub(/\^tm/, "<sup><small>™</small></sup>")            # trademark symbol

    
        #if list
        if text.match(/^\* (.*)/)
            list = "<ul>"
            text.scan(/^\* (.*)/) do |match|
                list += "<li>#{$1}</li>"
            end
            list += "</ul>"
            text = text.gsub(/(.*?)\*((.*|\n)*)/, "\\1") + list
        end

        return text
    end
end