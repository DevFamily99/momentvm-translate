class LwTranslationDocument
  require 'uri'
  require 'net/http'
  attr_accessor :frames
  attr_accessor :origin_language
  attr_accessor :distant_key # The ID once created at LW

  def initialize
    self.frames = []
    self.origin_language = 'en-GB'
  end

  # Mirrors the LW Frame concept
  # Convenience method, takes care of the frames
  def add_content(content)
    frame = LwTranslationFrame.new
    frame.text = content
    frames << frame
  end

  # Convenience method for create and validate
  def send_and_validate
    puts 'send_and_validate'
    create do |error, response|
      if error.nil?
        puts "no errors in creating document. LW project ID: #{distant_key}"
        validate do |validation_error|
          if validation_error.nil?
            yield nil
            return
          else
            yield "Couldnt validate. #{validation_error}"
            return
          end
        end
      else
        puts "document could not be created #{response}"
        yield "Couldnt create translation. #{response}. #{response}"
        return
      end
    end
  end

  # Yields errors, response
  # Creates document
  def create
    header = {
      'User-Agent' => Rails.configuration.lw[:user_agent],
      'Authorization' => Rails.configuration.lw[:secret],
      'Content-type' => 'application/vnd.lw.api+json',
      'X-Language' => origin_language
    }
    target_url = Rails.configuration.lw[:endpoint] + '/documents'
    uri = URI.parse target_url
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ssl_version = :TLSv1_2
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, header)
    body = {
      frames: frames
    }

    linebreak = '<span data-linebreak></span>'.to_json.gsub('"', '')
    trademark_r = '\\u003csup\\u003e\\u003csmall\\u003e®\\u003c/small\\u003e\\u003c/sup\\u003e'
    trademark_tm = '\\u003csup\\u003e\\u003csmall\\u003e™\\u003c/small\\u003e\\u003c/sup\\u003e'

    body = body.to_json.to_s.gsub(trademark_r, '__TRADEMARK-R__').gsub(trademark_tm, '__TRADEMARK-TM__').gsub('\n', linebreak)

    request.body = body
    response = http.request(request)
    # puts "Document Request:"
    puts response.to_hash
    case response.code.to_i
    when 201
      response_body = JSON.parse(response.body)
      self.distant_key = response_body['id']
      yield nil, distant_key
    else
      yield response, JSON.parse(response.body)
    end
  end

  # Yields error
  # Requests validation of document
  def validate
    header = {
      'User-Agent' => Rails.configuration.lw[:user_agent],
      'Authorization' => Rails.configuration.lw[:secret],
      'Content-Length' => '0'
    }
    target_url = Rails.configuration.lw[:endpoint] + "/documents/#{distant_key}/validation"
    uri = URI.parse target_url
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ssl_version = :TLSv1_2
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, header)
    response = http.request(request)
    case response.code.to_i
    when 202
      puts 'validation ok'
      yield nil
    when 409
      puts 'Was validated before'
      yield response
    else
      puts 'Validation error, response.code'
      p response.body
      yield response
    end
  end
  end
