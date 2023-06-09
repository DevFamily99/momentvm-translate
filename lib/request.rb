# Generic Request
# v0.9
require "uri"
require "net/http"

class Request
  # Yields resonse_code (int), response
  # Parameters besides url: are optional
  def send_request(url:, body: {}, header: {}, options: {})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if options.key? :type
      case options[:type]
      when :get
        request = Net::HTTP::Get.new(uri.request_uri, header)
      when :post
        request = Net::HTTP::Post.new(uri.request_uri, header)
      end
    else
      request = Net::HTTP::Get.new(uri.request_uri, header)
    end
    if options.key?(:username) && options.key?(:password)
      request.basic_auth options[:username], options[:password]
    end
    unless body.class == String
      body = body.to_json.to_s
    end
    request.body = body unless body.empty?
    # SSL is default
    if options.key? :ssl
      unless options[:ssl] == false
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    else
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    response = http.request(request)
    yield response.code.to_i, response
  end
end
