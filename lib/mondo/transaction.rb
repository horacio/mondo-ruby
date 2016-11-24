module Mondo
  class Transaction < Resource
    FIELDS = %i(
      id
      description
      notes
      metadata
      is_load
      category
      settled
      decline_reason
    ).freeze

    attr_accessor *FIELDS

    date_accessor :created, :settled

    def declined?
      raw_data['decline_reason'].present?
    end

    def amount
      Money.new(raw_data['amount'], currency)
    end

    def local_amount
      Money.new(raw_data['local_amount'], local_currency)
    end

    def account_balance
      Money.new(raw_data['account_balance'], currency)
    end

    def currency
      Money::Currency.new(raw_data['currency'])
    end

    def local_currency
      Money::Currency.new(raw_data['local_currency'])
    end

    def save_metadata
      client.api_patch("/transactions/%i" % id, metadata: metadata)
    end

    def register_attachment(options = {})
      attachment = Attachment.new({
        external_id: id,
        file_url:    options.fetch(:file_url),
        file_type:   options.fetch(:file_type)
      }, client)

      attachments << attachment if attachment.register
    end

    def attachments
      transactions ||= begin
        raw_data['attachments'].map do |attachment|
          Attachment.new(attachment, client)
        end
      end
    end

    def merchant
      unless raw_data['merchant'].kind_of?(Hash)
        # Go and refetch the transaction with merchant information expanded
        raw_data['merchant'] =
          client.transaction(id, expand: [:merchant]).raw_data['merchant']
      end

      if raw_data['merchant'].present?
        ::Merchant.new(raw_data['merchant'], client)
      end
    end

    def tags
      metadata["tags"]
    end

    def tags=(t)
      metadata["tags"] = t
    end
  end
end
