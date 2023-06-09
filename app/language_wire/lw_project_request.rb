# Project GET Request containing Projects
require 'request'
# A LwProjectRequest is a cms specific object that simplifies the creation and
# retrieval of projects
#
# status in lw documentation:
#    0: active, Translation is in progress, although translations for some languages might be already available.
#    1: finished, All documents are translated to all languages.
#    2: All translations are cancelled.
class LwProjectRequest < Request
  require 'uri'
  require 'net/http'
  attr_accessor :deadline
  attr_accessor :correlation_id # page.id
  attr_accessor :assignments # LwAssignment[]
  attr_accessor :status

  def initialize(params = {})
    self.correlation_id = params.fetch(:correlation_id, nil)
    # defaults
    self.assignments = []
    self.deadline = '2018-12-12T06:30:00Z'
  end

  # Currently not used
  # Check if project is still pending
  def pending?
    # uri = URI(Rails.configuration.lw[:endpoint] + "/projects/pending")
    uri = URI(Rails.configuration.lw[:endpoint] + '/projects/pending')
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
    puts '>>> Project request response:'
    puts res
    case res.code.to_i
    when 200
      body = JSON.parse(res.body)
      if body.any? { |element| element['correlationId'] == correlation_id }
        yield nil, true
      else
        yield nil, false
      end
    else
      yield "error. #{res}", true
    end
  end

  # Check if project is still pending
  # Parses ready assignments to self
  # use assignments property for accessing them
  def get_pending_projects
    send_request(
      url: Rails.configuration.lw[:endpoint] + '/projects/pending',
      options: {
        type: :get
      },
      header: {
        'User-Agent' => Rails.configuration.lw[:user_agent],
        'Authorization' => Rails.configuration.lw[:secret]
      }
    ) do |resp_code, resp|
      if resp_code == 200
        yield resp
      else
        yield nil
      end
    end
  end

  # Check if project is still pending
  # Parses ready assignments to self
  # use assignments property for accessing them
  # yields assignments
  def retrieve_parse_project
    # uri = URI(Rails.configuration.lw[:endpoint] + "/projects/pending")
    uri = URI(Rails.configuration.lw[:endpoint] + "/projects/#{correlation_id}")
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
    puts '>>> Project request response:'
    puts res
    puts res.code
    case res.code.to_i
    when 200
      body = JSON.parse(res.body)
      yield 'response error, no status' unless body.key? 'status'
      self.status = body['status']
      if status == 999 # 1
        yield 'not done'
        return
      end
      unless body.key? 'info'
        yield 'response error'
        return
        unless body['info'].key? 'assignments'
          yield 'response error'
          return
        end
      end
      self.correlation_id = body['info']['correlationId']
      puts correlation_id
      # Assignment are the different target lang
      body['info']['assignments'].each do |assignment|
        lwassignment = LwAssignment.new
        lwassignment.target_language = assignment['targetLanguage']
        lwassignment.distant_key = assignment['id'] # page id
        lwassignment.status = assignment['status']
        next unless assignment.key? 'documents'

        # each document is a page
        assignment['documents'].each do |document|
          # document["srourceDocument"]
          lwassignment_document = LwAssignmentDocument.new
          lwassignment_document.source_document = document['sourceDocument']
          lwassignment_document.delivered_document = document['deliveredDocument']
          lwassignment.documents << lwassignment_document
          assignments << lwassignment
        end
      end
      yield nil
      nil
    else
      # case default
      yield nil
      nil
    end
  end
end
