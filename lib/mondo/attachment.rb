module Mondo
  class Attachment < Resource
    FIELDS = %i(id user_id external_id file_url file_type url type).freeze

    attr_accessor *FIELDS
    date_accessor :created

    def register
      unless id
        client.api_post("attachment/register", registration_data)
      else
        raise ClientError.new("You have already registered this attachment")
      end
    end

    def deregister
      client.api_post("attachment/deregister", id: id)
    end

    def registration_data
      {
        external_id: external_id,
        file_url: file_url,
        file_type: file_type,
      }
    end
  end
end
