# GET /projects/{correlationId}
# Yields error
#
# A Project is one unit which is sent of to the agency
# It consists of multiple documents (maps to pages)
# A project has a deadline and a correlation_id which we set as the page id
#
#
#
class LwProject
  require 'uri'
  require 'net/http'
  attr_accessor :source_documents
  attr_accessor :target_languages
  attr_accessor :deadline
  attr_accessor :title
  attr_accessor :correlation_id # page.id
  attr_accessor :briefing

  def initialize
    self.source_documents = []
    self.target_languages = []
    self.deadline = ''
    self.title = ''
    self.briefing = ''
  end

  # Create project
  # Communicates with the external API
  def create
    uri = URI(Rails.configuration.lw[:endpoint] + '/projects')
    # Create client
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    dict = {
      'targetLanguages' => target_languages,
      'isDemo' => Rails.application.credentials.dig(ENV['CURRENT_INSTANCE'].to_sym, :languagewire, :demo_mode),
      'correlationId' => correlation_id.to_s,
      'product' => Rails.application.credentials.dig(ENV['CURRENT_INSTANCE'].to_sym, :languagewire, :product),
      'terminology' => Rails.application.credentials.dig(ENV['CURRENT_INSTANCE'].to_sym, :languagewire, :terminologies),
      'workArea' => Rails.application.credentials.dig(ENV['CURRENT_INSTANCE'].to_sym, :languagewire, :work_area),
      'sourceDocuments' => source_documents.flatten,
      'title' => title,
      'invoicingAccount' => Rails.application.credentials.dig(ENV['CURRENT_INSTANCE'].to_sym, :languagewire, :invoicing_account),
      'briefing' => briefing,
      'supplierBriefing' => briefing,
      'purchaseOrderNumber' => 'ABC-123456',
      'deadline' => deadline
    }
    # Create Request
    req = Net::HTTP::Post.new(uri)
    # Add headers
    req.add_field 'User-Agent', Rails.configuration.lw[:user_agent]
    # Add headers
    req.add_field 'Authorization', Rails.configuration.lw[:secret]
    # Add headers
    req.add_field 'Content-Type', 'application/json'
    # Set body
    req.body = dict.to_json.to_s
    puts '>>>>>>'
    puts req.body
    puts '>>>>>>'
    # Fetch Request
    res = http.request(req)
    case res.code.to_i
    when 202
      yield nil
    when 409
      yield '409. Conflict.'
    else
      puts '>>> Project request response:'
      puts res.code
      puts res.message
      puts source_documents.flatten.to_s
      yield res
    end
  end
end
