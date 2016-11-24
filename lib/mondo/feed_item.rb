module Mondo
  class FeedItem < Resource
    # TODO: Make 'url' consistent when the Mondo API changes
    FIELDS = %i(title image_url url background_color body type).freeze

    attr_accessor *FIELDS

    # TODO: Temporary fix until the API accepts JSON data in the request body
    def save
      client.api_post('/feed', create_params)
    end

    private

    def create_params
      {
        type: 'basic',
        account_id: client.account_id,
        url: url,
        params: {
          title: title,
          image_url: image_url,
          background_color: background_color,
          body: body
        }
      }
    end
  end
end
