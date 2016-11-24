module Mondo
  class Account < Resource
    FIELDS = %i(id account_number description sort_code).freeze

    attr_accessor *FIELDS
    date_accessor :created

    def balance
      client.balance(id)
    end
  end
end
