# A single page of one assignment (target lang)
class LwAssignmentDocument
  attr_accessor :source_document
  attr_accessor :delivered_document
  attr_accessor :frames
  def initialize
    self.frames = []
  end

  def ready?
    if delivered_document.nil?
      false
      # self.delivered_document = "1914504"
      # return true
    else
      # self.delivered_document = "1914504"
      true
    end
  end

  # Check if project is still pending
  def get_content
    # uri = URI(Rails.configuration.lw[:endpoint] + "/projects/pending")
    uri = URI(Rails.configuration.lw[:endpoint] + "/documents/#{delivered_document}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    # Create Request
    req = Net::HTTP::Get.new(uri)
    # Add headers
    req.add_field 'User-Agent', Rails.configuration.lw[:user_agent]
    # Add headers
    req.add_field 'Authorization', Rails.configuration.lw[:secret]
    # Add headers
    req.add_field 'Content-Type', 'application/json'
    res = http.request(req)
    case res.code.to_i
    when 200
      body = JSON.parse(res.body)
      yield 'no frames found' unless body.key? 'frames'
      body['frames'].each do |frame|
        # frame["text"]
        lwframe = LwTranslationFrame.new
        lwframe.text = frame['text']
        lwframe.metadata = frame['metadata']
        # frame["metadata"]["translation_id"]
        frames << lwframe
      end
      yield nil
    else
      puts "Get delivered document. #{res}"
      yield "error. #{res}"
    end
  end
end
