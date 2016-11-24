module Mondo
  class WebHook < Resource
    attr_accessor :id, :account_id, :url

    def save
      client.api_post("webhooks", account_id: account_id, url: url)
    end
  end
end
